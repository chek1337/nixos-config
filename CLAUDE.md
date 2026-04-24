# CLAUDE.md

Orientation for Claude Code. See `README.md` for the full story; this file is
the short version plus repo-specific tooling notes.

## Project overview

Personal NixOS config using the **dendritic** pattern: `flake-parts` wires
top-level outputs, `import-tree ./modules` auto-imports every `*.nix` under
`modules/`, and `./nvf` adds the declarative Neovim config. Three hosts:
`desktop-home`, `laptop-asus`, `wsl-asuslaptop`. Themes via Stylix, secrets
via sops-nix, deploys wrapped by `nh` through `just`.

## Layout

```
flake.nix                    # flake-parts entry, inputs
justfile                     # build / deploy recipes (wraps nh)
modules/
  flake/                     # flake-parts pieces, NixOS classes, profiles
  hosts/<host>/              # one dir per host
  programs/                  # cli-tools, gui-tools, gaming, mail, terminals
  services/                  # docker, wireguard, virtualization, ...
  hardware/                  # bluetooth, power, asus-laptop, wsl-nvidia, ...
  shells/ desktop-env/ themes/
nvf/                         # declarative Neovim (exposes a standalone pkg)
nvim/                        # legacy lazyvim-nix config, kept for reference
secrets/                     # sops-encrypted
```

Modules self-register: any new `*.nix` under `modules/` is picked up by
`import-tree` with no central import list to edit.

## Commands I may run

Safe (local, read-only or build-only):

- `just fmt` — format all Nix files via nixfmt.
- `just check` — `nix flake check`.
- `just b <host>` — build without applying.
- `just t <host>` — test without applying.

Do **not** run without explicit user instruction — these mutate the live
system or reboot config:

- `just sw / nsw / hm / bo / nbo <host>` (any `nh os|home switch|boot`).
- `just gc`, `just hw <host>`.

Never commit plaintext secrets. Everything sensitive lives under `secrets/`
encrypted with sops (see `.sops.yaml`).

## Package & option lookup with `nix-search-tv`

`nix-search-tv` is a CLI that serves indexed nixpkgs packages and
NixOS / home-manager options. Use it for any "what does this package do?"
or "what parameters does this option take?" question instead of guessing or
browsing search.nixos.org.

Current config (`~/.config/nix-search-tv/config.json`, HM-managed) enables:
`nixpkgs`, `nixos`, `home-manager`, `nur`, `noogle`. Because multiple indexes
are active, `preview` / `source` / `homepage` must be scoped with
`--indexes <one>` to disambiguate.

### Analyze a nixpkgs package

| Command | Output |
|---|---|
| `nix-search-tv preview --indexes nixpkgs <pkg>` | name, version, description, homepage, license, main program, platforms |
| `nix-search-tv preview --indexes nixpkgs --json <pkg>` | same data as JSON |
| `nix-search-tv source --indexes nixpkgs <pkg>` | GitHub link to the Nix declaration |
| `nix-search-tv homepage --indexes nixpkgs <pkg>` | upstream project URL |

### Study option parameters (NixOS / home-manager)

| Command | Output |
|---|---|
| `nix-search-tv preview --indexes nixos <option.path>` | description, `type`, `default`, `example`, declared-in |
| `nix-search-tv preview --indexes home-manager <option.path>` | same, for HM options |
| `nix-search-tv source --indexes nixos <option.path>` | link to the module that declares it |

Example:

```
nix-search-tv preview --indexes nixos services.openssh.enable
nix-search-tv preview --indexes home-manager programs.git.enable
```

### Fuzzy search without a TUI

Subcommands need an **exact** name. When the name is unknown, list + filter
non-interactively with `fzf -f`, then preview the best hit:

```
nix-search-tv print --offline --indexes nixos \
  | fzf -f 'openssh enable' \
  | head -1 \
  | xargs -I{} nix-search-tv preview --indexes nixos {}
```

Swap `--indexes nixos` for `nixpkgs` / `home-manager` as needed.

### Gotchas

- `--indexes` is a **per-subcommand** flag, not global. Repeat it to pass
  multiple values: `--indexes nixpkgs --indexes nixos`.
- `--offline` exists **only on `print`**; it skips refetching indexes.
  `preview` / `source` / `homepage` always read from cache.
- Only `preview` supports `--json`; everything else is plain text.
- Without `--indexes`, multi-index configs error with
  `multiple indexes requested, but the package has no index prefix`.

## Memory

Persistent user preferences live under
`~/.claude/projects/-home-chek-nixos-config/memory/` and auto-load into
context. Example currently in effect: commits in this repo omit the
`Co-Authored-By: Claude` trailer.
