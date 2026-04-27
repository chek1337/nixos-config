# Multi-root workspace

VS Code-like multi-root workspace management for Neovim, implemented as a
small in-tree Lua module wired through nvf.

The feature solves one problem: opening several folders that live in
unrelated places on the filesystem (for example `~/code/repo-a`,
`/srv/projects/lib-x`, `~/scratch/notes`) inside one Neovim session, and
keeping LSP servers aware of all of them as a multi-root workspace.

## How it works

State of the active workspace is held in two globals:

- `vim.g.workspace_folders` — list of absolute folder paths.
- `vim.g.workspace_name` — name of the loaded `.code-workspace`, or `nil`.

These are the source of truth. Any external integration (statusline,
tabline, etc.) can read them and subscribe to the `User WorkspaceChanged`
autocmd to react to changes.

LSP integration happens in two places:

1. **Server start (`before_init`).** A wildcard `vim.lsp.config("*", …)`
   hook augments `params.workspaceFolders` of every new LSP client with
   the user's workspace folders. The server's auto-detected root
   (`params.rootUri` / `params.rootPath`, computed by Neovim from the
   server's `root_markers`) is **prepended** as the first folder, deduped
   by URI. Workspace folders augment, never replace, the auto-detected
   root — so project configs (`pyrightconfig.json`, `.luarc.json`,
   `Cargo.toml`, …) are still discovered when the user's workspace
   contains only a sub-folder of the project.

2. **Runtime change (`workspace/didChangeWorkspaceFolders`).** When a
   folder is added or removed at runtime, the module diffs old vs. new
   and notifies every active LSP client that advertises both
   `workspace.workspaceFolders.supported` and `.changeNotifications`.
   Clients without `changeNotifications` (notably **clangd**) get a
   warning that asks for `:LspRestart`. No silent restarts.

## Registry

Workspace files live in a global registry at:

```
~/.config/nvim-workspaces/<name>.code-workspace
```

The directory is created lazily on first edit. Contents are plain
JSON — VS Code workspace format:

```json
{
  "folders": [
    { "path": "/home/chek/code/repo-a" },
    { "path": "/srv/projects/lib-x" },
    { "path": "/home/chek/scratch/notes" }
  ]
}
```

Both absolute paths and paths relative to the workspace file's directory
are accepted (relative paths are resolved on load). Missing folders are
filtered out with a warning, the rest still load.

Workspace files are authored by editing them directly via `:WorkspaceEdit`
(picker over the registry, opens the chosen JSON in a buffer). On an
empty registry it prompts for a name and opens a fresh file.

Bootstrap policy: Neovim **starts with an empty workspace**. Activate
manually via `:WorkspaceLoad`.

## Commands

| Command | Behavior |
|---|---|
| `:WorkspaceLoad [name]` | With a name argument: load `<name>.code-workspace` from the registry. Without: open a Snacks picker over the registry. Tab-completes registry entries. |
| `:WorkspaceEdit [name]` | Open a workspace JSON for direct editing. With a name: opens that file (creating it if missing). Without: picker over the registry, or prompt for a new name if registry is empty. |
| `:WorkspaceList` | Echo the active workspace name and folders. |
| `:WorkspaceClear` | Drop the active workspace. State becomes empty, all folders are sent as `removed` to LSP clients, picker overrides fall back to the active buffer's project root (or cwd if no root marker is found). |
| `:WorkspaceLspInfo` | Print `root_dir` and current `workspaceFolders` for every active LSP client. Diagnostic only. |

## Keymaps (`<leader>w` namespace)

| Key | Action |
|---|---|
| `<leader>wl` | `:WorkspaceLoad` (picker) |
| `<leader>we` | `:WorkspaceEdit` (picker → edit JSON) |
| `<leader>wL` | `:WorkspaceList` |
| `<leader>wc` | `:WorkspaceClear` |

The `<leader>w` group is registered with which-key as `"Workspace"`.

## Lua API

The module is registered as `chek.workspace` and can be required from
anywhere:

```lua
local ws = require("chek.workspace")

ws.current()                    -- list<string> of absolute paths
ws.name()                       -- string|nil
ws.load("name")
ws.list()
ws.clear()                      -- drop active workspace
ws.pick()                       -- opens the load picker
ws.edit()                       -- opens the edit picker
ws.edit("name")                 -- opens (or creates) <name>.code-workspace
ws.parse_workspace_file(path)   -- returns list<abs path> from a file
```

To react to changes:

```lua
vim.api.nvim_create_autocmd("User", {
  pattern  = "WorkspaceChanged",
  callback = function()
    -- e.g. refresh statusline section
  end,
})
```

## Snacks picker integration

When a workspace is active, the `Root Dir` flavour of snacks pickers is
re-scoped to the workspace folders by passing `dirs = workspace_folders`
to the picker. The cwd-explicit variants are left alone, so the user can
still escape the workspace scope on demand.

| Key | Behavior with workspace | Without workspace |
|---|---|---|
| `<leader>ff` | files across workspace folders | files in buffer's project root, else cwd |
| `<leader>fr` | recent files filtered by workspace | recent in buffer's project root, else cwd |
| `<leader>sg` | grep across workspace folders | grep in buffer's project root, else cwd |
| `<leader>sw` | grep word across workspace folders | grep word in buffer's project root, else cwd |
| `<leader>fF`, `<leader>sG`, `<leader>sW` | unchanged (cwd) | unchanged (cwd) |

The "buffer's project root" is resolved by walking up from the active buffer's file, looking for any of a curated set of markers (`.git`, `flake.nix`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `package.json`, `composer.json`, `pom.xml`, `CMakeLists.txt`, `Makefile`, `.luarc.json`, etc. — full list in `picker.nix`). `vim.fs.root` returns the closest matching ancestor, so a sub-project inside a monorepo resolves to its own dir. If no marker is found (or the buffer has no file), the picker falls back to its default cwd (`vim.fn.getcwd()`).

Implementation lives in `picker.nix` as a `luaConfigRC` override that
re-binds the keys after nvf has applied the original snacks bindings.

## File layout

```
nvf/plugins/workspace/
├── default.nix      -- import-tree
├── module.nix       -- Lua module + commands + keymaps
├── lsp.nix          -- vim.lsp.config("*", { before_init = … })
├── picker.nix       -- snacks.picker overrides for <leader>{ff,fr,sg,sw}
├── which-key.nix    -- registers "<leader>w" = "Workspace"
└── doc.md           -- this file
```

All workspace-related configuration is contained in this folder. No
edits required to `nvf/lsp.nix` or the global `which-key.nix`.

## LSP capability handling

For each active client the module inspects:

```
client.server_capabilities.workspace.workspaceFolders.supported
client.server_capabilities.workspace.workspaceFolders.changeNotifications
```

| `supported` | `changeNotifications` | Behavior on load/clear |
|---|---|---|
| `true` | truthy | Send `workspace/didChangeWorkspaceFolders` |
| `true` | falsy | Warn: `<server>: no changeNotifications, run :LspRestart` |
| falsy | — | Skip silently (server is single-root only) |

Servers known to fully support runtime changes: `lua_ls`, `gopls`,
`rust-analyzer`, `pyright`, `basedpyright`, `ty`, `vtsls`, `nixd`.

Servers that need a manual restart on change: `clangd` (it accepts
`workspaceFolders` at init but ignores runtime updates because its index
is rooted to the initial root_dir).

## Caveats

- The wildcard `vim.lsp.config("*", { before_init = … })` is a default
  for all servers. If another module sets `before_init` for a specific
  server, that per-server hook overrides this one and the workspace
  folders will not be injected for that server.
- Augmentation only applies when a workspace is active (`#folders > 0`).
  With no workspace loaded, server initialization is left untouched —
  Neovim's default `root_markers`-based resolution is used as-is.
- Buffers from a folder added at runtime may not auto-attach to an
  existing client depending on Neovim's root-detection logic. If LSP
  features are missing, `:LspRestart` for the buffer.
- Path normalization uses `vim.fs.normalize` plus `:p`, so symlinks are
  not resolved. Two different paths pointing to the same target via a
  symlink are treated as distinct entries.
