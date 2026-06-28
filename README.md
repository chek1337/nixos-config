# NixOS Config

My personal NixOS configuration using the **dendritic** modular pattern with [flake-parts](https://github.com/hercules-ci/flake-parts) and [import-tree](https://github.com/vic/import-tree).

## Screenshots

![Nord](assets/example/nord-example-1.png)
![Catppuccin Mocha](assets/example/catppuccin-mocha-example-1.png)
![Gruvbox Dark Hard](assets/example/gruvbox-dark-hard-example-1.png)

## Features

- **Modular architecture** — self-registering modules organized by category with aggregate profiles
- **Multi-host** — single flake for desktop (home + workstation), laptop (ASUS TUF A15), and WSL
- **Wayland-native** — Niri compositor with Noctalia shell
- **Themes** (Nord, Catppuccin Mocha, Gruvbox Dark Hard) via [Stylix](https://github.com/danth/stylix)
- **Secrets management** with [sops-nix](https://github.com/Mic92/sops-nix)
- **Neovim** configured declaratively through [nixvim](https://github.com/nix-community/nixvim) with 30+ plugins
- **just** commands for all common operations

## Structure

```
.
├── flake.nix                 # Entry point
├── justfile                  # Build/deploy commands
├── modules/
│   ├── flake/                # Core: flake-parts, configurations, system classes
│   │   ├── nixos-classes/    # nixos, wsl, boot, sops, settings, installer
│   │   └── profiles/         # Aggregate profiles (base, desktop, workstation, etc.)
│   ├── hosts/
│   │   ├── desktop-home/     # Desktop with Niri WM
│   │   ├── desktop-work/     # Workstation flavor (no gaming/media-production/waydroid)
│   │   ├── laptop-asus/      # ASUS TUF A15 laptop (Niri WM + nixos-hardware)
│   │   └── wsl-asuslaptop/   # WSL environment
│   ├── programs/
│   │   ├── cli-tools/        # bat, btop, eza, git, nixvim, tmux, yazi, zellij, cmus...
│   │   ├── gui-tools/        # telegram, spicetify, libreoffice, mpv, zathura, imv, nautilus...
│   │   │   ├── gui-browsers/ # firefox, zen, librewolf, qutebrowser, yandex-browser
│   │   │   └── gui-code-editors/ # vscode, sublime
│   │   ├── gaming/           # steam, wine, bottles, lutris, mangohud
│   │   ├── mail/             # thunderbird, aerc
│   │   └── terminals/        # alacritty, kitty, wezterm
│   ├── services/             # docker, wireguard, wireproxy, vopono, networking, virtualization, pttkey, push2talk, throne, zmkbatx
│   ├── hardware/             # bluetooth, power, asus-laptop-hardware, usb-automount, wsl-nvidia
│   ├── shells/               # zsh, nu, direnv
│   ├── desktop-env/          # niri, noctalia, wayland-common
│   └── themes/               # nord, catppuccin-mocha, gruvbox-dark-hard
├── nixvim/                   # Neovim configuration via nixvim (declarative, 30+ plugins)
│   ├── default.nix           # Entry point
│   ├── nixvim.nix            # home-manager module
│   ├── keymaps.nix           # Keybindings
│   ├── options.nix           # Vim options
│   └── plugins/              # Plugin configs (snacks, harpoon, flash, blink, etc.)
├── packages/                 # Standalone flake packages/apps
│   ├── nvim.nix              # Neovim standalone package/app
│   ├── tmux.nix
│   ├── yazi.nix
│   └── kitty.nix
└── secrets/                  # Encrypted secrets (sops)
```

## Profiles

Profiles aggregate related modules to simplify host configs:

| Profile | Includes |
|---------|----------|
| `base` | nord, zsh, cli-tools, dev-tools, docker, terminals |
| `desktop-base` | sops, bluetooth, power, wayland-common |
| `desktop` | base, gui-tools, desktop-base, niri, noctalia, wireshark |
| `dev-tools` |  direnv, python-dev |
| `workstation` | virtualization, mail, pttkey, usb-automount, zmkbatx |
| `home-extras` | kdenlive, obs, image-editors, discord, qbittorrent |
| `homestation` | workstation, gaming, waydroid, home-extras |

## Hosts

| Host | Type | WM | Shell | Profiles & Modules |
|------|------|----|-------|--------------------|
| `desktop-home` | NixOS desktop | Niri | Zsh | desktop, homestation, networking |
| `desktop-work` | NixOS workstation | Niri | Zsh | desktop, workstation, networking |
| `laptop-asus` | NixOS laptop (ASUS TUF A15) | Niri | Zsh | desktop, homestation, networking, asus-laptop-hardware |
| `wsl-asuslaptop` | WSL | — | Zsh | base, wsl-nvidia, sops, vopono |

## Installation

```bash
# Prerequisites: NixOS installed. Flakes + nix-command don't need to be
# enabled globally - the `just` targets pass --extra-experimental-features.
# https://nixos.org/download/

# Enter a temporary shell with required tools
nix-shell -p git just nh

# Clone the repository
git clone https://github.com/chek1337/nixos-config.git ~/nixos-config
cd ~/nixos-config

# Generate hardware config for your machine
just hw <hostname>

# Apply NixOS only on next boot — do NOT run Home Manager yet.
# Stylix writes GTK theme keys via dconf, and dconf needs a live
# user D-Bus session that doesn't exist before the first graphical
# login. Running HM here will fail at activation.
just nboinit <hostname>
reboot

# Log in to your graphical session or switch to a TTY (usually Ctrl+Alt+F2..F6).
# This starts user D-Bus and dconf, which are required for Home Manager
# activation (Stylix).

# Now apply Home Manager (first time: uses standard home-manager switch)
just hminit <hostname>
reboot

# (Optional) Setup sops secrets for encrypted configs
# Derives an age key from an existing SSH key under ~/.ssh and writes it
# to ~/.config/sops/age/keys.txt with mode 600.
just sops-init <key>

# Fix SSH key permissions, (re)load the key into ssh-agent, verify GitHub auth.
# SSH refuses keys with overly-open modes; `ssh-add -D` clears stale entries.
just ssh-init <key>
# Expected: Hi <user>! You've successfully authenticated...

# Switch origin to SSH
git remote set-url origin git@github.com:<user>/<repo>.git
```

If `git push` fails with `agent refused operation` / `Permission denied (publickey)`, the cause is almost always wrong file modes on the private key or a stale entry in ssh-agent — `just ssh-init <key>` fixes both.

### Commands

Deploy recipes wrap [nh](https://github.com/nix-community/nh) (nvd diff + nix-output-monitor).

```bash
just                              # Show all available commands

# Init (first-time setup, standard NixOS tooling — no nh)
just nboinit <host>               # nixos-rebuild boot + activate git hooks (first install)
just hminit <host>                # home-manager switch for first-time HM activation
just sops-init <key>              # Derive sops age key from ~/.ssh/<key>
just ssh-init <key>               # Fix SSH key perms, reload ssh-agent, verify GitHub auth

# Deploy (wrap nh)
just sw <host>                    # Apply NixOS + Home Manager configuration
just nsw <host>                   # Apply NixOS only
just hm <host>                    # Apply Home Manager only
just t <host>                     # Test without applying
just b <host>                     # Build without applying
just bo <host>                    # Apply NixOS on next boot + Home Manager now
just nbo <host>                   # Apply NixOS on next boot only

# Utils
just hw <host>                    # Generate hardware config for given host
just up                           # Update all flake inputs
just up <input>                   # Update specific flake input
just gc                           # Garbage collect old generations via nh
just fmt                          # Format all nix files
just check                        # nix flake check
just iso <host>                   # Build offline installation ISO
```

## Standalone Packages

This flake also exposes standalone packages/apps that can be used outside this NixOS configuration:

- `nvim` — declarative Neovim configuration via nixvim
- `tmux` — wrapped tmux configuration with bundled plugins and runtime tools
- `zoxide` — zoxide binary plus a ready-to-source zsh init
- `kitty` — wrapped kitty configuration with the nord palette baked in (Mesa/Intel/AMD via nixGL)
- `kitty-nvidia` — same, but wrapped in nixGLNvidia (driver version pinned)

See [STANDALONE.md](STANDALONE.md) for installation and flake integration examples.

## Offline Installation (ISO)

See [OFFLINE-INSTALLATION.md](OFFLINE-INSTALLATION.md) for building the ISO and installing NixOS without network access.

## Inspiration

- [Doc-Steve/dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)
- [onatustun/nix-config](https://github.com/onatustun/nix-config)
- [TheMaxMur/NixOS-Configuration](https://github.com/TheMaxMur/NixOS-Configuration)
- [khaneliman/khanelinix](https://github.com/khaneliman/khanelinix)
