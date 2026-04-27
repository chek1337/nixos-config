# Multi-root workspace (picker scope)

VS Code-like multi-root workspace for Neovim, implemented as a small
in-tree Lua module wired through nvf.

The feature solves one problem: keeping a named set of folders that live
in unrelated places on the filesystem (for example `~/code/repo-a`,
`/srv/projects/lib-x`, `~/scratch/notes`) and using that set to scope
file/grep pickers across all of them at once.

LSP integration is intentionally out of scope — Neovim's per-buffer
`root_markers` resolution handles that on its own. This module only
publishes workspace state and wires it into Snacks pickers.

## How it works

State of the active workspace is held in two globals:

- `vim.g.workspace_folders` — list of absolute folder paths.
- `vim.g.workspace_name` — name of the loaded `.code-workspace`, or `nil`.

These are the source of truth. Any external integration (statusline,
tabline, picker, etc.) can read them and subscribe to the
`User WorkspaceChanged` autocmd to react to changes.

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
| `:WorkspaceClear` | Drop the active workspace. State becomes empty; picker overrides fall back to the active buffer's project root (or cwd if no root marker is found). |

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
├── picker.nix       -- snacks.picker overrides for <leader>{ff,fr,sg,sw}
├── which-key.nix    -- registers "<leader>w" = "Workspace"
└── doc.md           -- this file
```

All workspace-related configuration is contained in this folder. No
edits required to `nvf/lsp.nix` or the global `which-key.nix`.

## Caveats

- Path normalization uses `vim.fs.normalize` plus `:p`, so symlinks are
  not resolved. Two different paths pointing to the same target via a
  symlink are treated as distinct entries.
- LSP is unaware of workspace folders. Each buffer attaches to whatever
  client Neovim resolves from its own `root_markers`. Cross-folder
  features (workspace symbols, go-to-def into a sibling repo's source)
  rely on the LSP server's own indexing of files reachable from that
  per-buffer root, not on the workspace set.
