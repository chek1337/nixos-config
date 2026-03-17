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
| `generic` | NixOS desktop (universal) | Niri | Zsh | desktop-home without hardware-specific modules |
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
just iso <host>   # Build offline installation ISO
```

## Offline Installation (ISO)

Build an ISO containing all packages for offline NixOS installation on any x86_64 machine.

### Build ISO

```bash
just iso generic
# or interactively:
just isoi
```

Write to USB:
```bash
dd if=result-iso/iso/*.iso of=/dev/sdX bs=4M status=progress
```

### Install: Clean Disk

Boot from USB, then:

```bash
# Partition
parted /dev/nvme0n1 mklabel gpt
parted /dev/nvme0n1 mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 set 1 esp on
parted /dev/nvme0n1 mkpart swap linux-swap 512MiB 4.5GiB
parted /dev/nvme0n1 mkpart nixos ext4 4.5GiB 100%

# Format (labels recommended)
mkfs.fat -F32 -n boot /dev/nvme0n1p1
mkswap -L swap /dev/nvme0n1p2
mkfs.ext4 -L nixos /dev/nvme0n1p3

# Mount
mount /dev/nvme0n1p3 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
swapon /dev/nvme0n1p2

# Generate hardware config and install
nixos-generate-config --root /mnt --show-hardware-config \
  > /etc/nixos-config/modules/hosts/generic/_hardware-configuration.nix

nixos-install --flake /etc/nixos-config#generic --no-channel-copy

# Set user password
nixos-enter --root /mnt -c 'passwd chek'

reboot
```

### Install: Dual Boot (Windows + NixOS)

Shrink Windows partition first (in Windows Disk Management), then boot from USB:

```bash
# Check existing layout
lsblk

# Create NixOS partitions in free space (keep existing EFI!)
parted /dev/nvme0n1 mkpart swap linux-swap <start> <start+4G>
parted /dev/nvme0n1 mkpart nixos ext4 <start+4G> 100%

mkswap -L swap /dev/nvme0n1pX
mkfs.ext4 -L nixos /dev/nvme0n1pY

# Mount (use existing Windows EFI partition)
mount /dev/nvme0n1pY /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot    # existing EFI
swapon /dev/nvme0n1pX

# Generate hardware config and install
nixos-generate-config --root /mnt --show-hardware-config \
  > /etc/nixos-config/modules/hosts/generic/_hardware-configuration.nix

nixos-install --flake /etc/nixos-config#generic --no-channel-copy
nixos-enter --root /mnt -c 'passwd chek'

reboot
```

> systemd-boot will automatically detect Windows Boot Manager on the EFI partition.

## Inspiration

- [Misterio77/nix-config](https://github.com/Misterio77/nix-config)
- [NotAShelf/nyx](https://github.com/NotAShelf/nyx)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)

## License

[MIT](LICENSE)
