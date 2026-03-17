# NixOS Config

My personal NixOS configuration using the **dendritic** modular pattern with [flake-parts](https://github.com/hercules-ci/flake-parts) and [import-tree](https://github.com/vic/import-tree).

## Screenshots

<!-- Add your screenshots here -->
<!--
![Desktop](assets/screenshot1.png)
![Terminal](assets/screenshot2.png)
-->

> *Screenshots coming soon*

## Features

- **Modular architecture** — self-registering modules organized by category
- **Multi-host** — single flake for desktop (Niri WM) and WSL environments
- **Wayland-native** — Niri / Hyprland with Noctalia shell
- **Nord theme** via [Stylix](https://github.com/danth/stylix)
- **Secrets management** with [sops-nix](https://github.com/Mic92/sops-nix)
- **Neovim** configured through [nvf](https://github.com/notashelf/nvf)
- **just** commands for all common operations

## Structure

```
.
├── flake.nix                 # Entry point
├── justfile                  # Build/deploy commands
├── modules/
│   ├── flake/                # Core: flake-parts, configurations, system classes
│   │   └── nixos-classes/    # nixos, wsl, boot, sops
│   ├── hosts/
│   │   ├── desktop-home/     # Desktop with Niri WM
│   │   └── wsl-asuslaptop/  # WSL environment
│   ├── programs/
│   │   ├── cli-tools/        # bat, btop, eza, git, nvim, tmux...
│   │   ├── gui-tools/        # discord, telegram, spicetify...
│   │   └── terminals/        # alacritty, kitty, wezterm
│   ├── services/             # docker, wireguard, zapret...
│   ├── hardware/             # bluetooth, power, wsl-nvidia
│   ├── shells/               # zsh, nu
│   ├── desktop-env/          # niri, hyprland, noctalia, wayland utils
│   └── themes/               # nord
├── nvim/                     # Neovim configuration
└── secrets/                  # Encrypted secrets (sops)
```

## Hosts

| Host | Type | WM | Shell | Modules |
|------|------|----|-------|---------|
| `desktop-home` | NixOS desktop | Niri | Zsh | cli-tools, gui-tools, wayland, bluetooth, docker, noctalia |
| `wsl-asuslaptop` | WSL | — | Zsh | cli-tools, python-dev, docker, kitty |

## Installation

### Prerequisites

- [NixOS](https://nixos.org/download/) installed
- [Nix flakes](https://wiki.nixos.org/wiki/Flakes) enabled
- [just](https://github.com/casey/just) command runner

### Clone

```bash
git clone https://github.com/<your-username>/nixos-config.git ~/nixos_config
cd ~/nixos_config
```

### Setup sops secrets

```bash
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run \
  "ssh-to-age -private-key < ~/.ssh/<your-key>" > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

### Generate hardware config

```bash
just hw <hostname>
```

### Apply configuration

```bash
# Switch to new configuration
just sw <hostname>

# Or interactively select host
just swi
```

### Other commands

```bash
just              # Show all available commands
just t <host>     # Test without applying
just b <host>     # Build without applying
just bo <host>    # Apply on next boot
just up           # Update all flake inputs
just gc           # Garbage collect old generations
just fmt          # Format all nix files
```

## Inspiration

- [Misterio77/nix-config](https://github.com/Misterio77/nix-config)
- [NotAShelf/nyx](https://github.com/NotAShelf/nyx)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)

## License

[MIT](LICENSE)
