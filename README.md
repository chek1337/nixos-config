# NixOS Config

My personal NixOS configuration using the **dendritic** modular pattern with [flake-parts](https://github.com/hercules-ci/flake-parts) and [import-tree](https://github.com/vic/import-tree).

## Screenshots

![Desktop](assets/example/main_screen.png)
![Working](assets/example/working.png)

## Features

- **Modular architecture** — self-registering modules organized by category
- **Multi-host** — single flake for desktop (Niri WM) and WSL environments
- **Wayland-native** — Niri / Hyprland with Noctalia shell
- **Nord theme** via [Stylix](https://github.com/danth/stylix)
- **Secrets management** with [sops-nix](https://github.com/Mic92/sops-nix)
- **Neovim** configured through [lazyvim-nix](https://github.com/pfassina/lazyvim-nix)
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
│   │   ├── generic/          # Universal desktop (for ISO)
│   │   └── wsl-asuslaptop/   # WSL environment
│   ├── programs/
│   │   ├── cli-tools/        # bat, btop, eza, git, nvim, tmux, yazi, zellij...
│   │   ├── gui-tools/        # discord, telegram, spicetify, wireshark...
│   │   └── terminals/        # alacritty, kitty
│   ├── services/             # docker, wireguard, vopono, networking, virtualization...
│   ├── hardware/             # bluetooth, power, wsl-nvidia
│   ├── shells/               # zsh, nu
│   ├── desktop-env/          # niri, hyprland, noctalia, wayland-common
│   └── themes/               # nord
├── nvim/                     # Neovim configuration
└── secrets/                  # Encrypted secrets (sops)
```

## Hosts

| Host | Type | WM | Shell | Modules |
|------|------|----|-------|---------|
| `desktop-home` | NixOS desktop | Niri | Zsh | cli-tools, gui-tools, terminals, desktop-env, niri, noctalia, docker, virtualization, networking, wireshark, python-dev, direnv, claude-code, zmkbatx |
| `generic` | NixOS desktop (universal) | Niri | Zsh | desktop-home without zmkbatx and virtualization |
| `wsl-asuslaptop` | WSL | — | Zsh | cli-tools, kitty, docker, vopono, python-dev, direnv, wsl-nvidia, sops |

## Installation

### Prerequisites

- [NixOS](https://nixos.org/download/) installed
- [Nix flakes](https://wiki.nixos.org/wiki/Flakes) enabled
- [just](https://github.com/casey/just) command runner

### Clone

```bash
git clone https://github.com/chek1337/nixos-config.git ~/nixos_config
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
just iso <hostname>
# or interactively:
just isoi
```

Write to USB:
```bash
dd if=result-iso/iso/*.iso of=/dev/sdX bs=4M status=progress
```

### Identify target disk

Boot from USB, then find the target disk:

```bash
lsblk
```

Example output:

```
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda           8:0    1   7.5G  0 disk            # <-- USB installer
├─sda1        8:1    1   3.2G  0 part
└─sda2        8:2    1    50M  0 part
nvme0n1     259:0    0 476.9G  0 disk            # <-- target disk
```

Pick the disk you want to install to — the one that matches the expected size and is **not** the USB installer. The installer is usually a small removable (`RM = 1`) device.

> In the examples below `DISK` is used as a placeholder (e.g. `/dev/sda`, `/dev/nvme0n1`, `/dev/vda`).
> Partitions are referred to as `DISKp1`, `DISKp2`, etc.

### Flake configuration path

The ISO mounts at `/iso`. The flake is available at:

```
/iso/etc/nixos-config
```

> The ISO filesystem is **read-only**. Copy the config to a writable location before making changes:
> ```bash
> cp -r /iso/etc/nixos-config /tmp/nixos-config
> ```
> All commands below use `/tmp/nixos-config` as the working copy.

### Install: Clean Disk

```bash
# Partition
parted /dev/DISK mklabel gpt
parted /dev/DISK mkpart ESP fat32 1MiB 512MiB
parted /dev/DISK set 1 esp on
parted /dev/DISK mkpart swap linux-swap 512MiB 4.5GiB
parted /dev/DISK mkpart nixos ext4 4.5GiB 100%

# Format
mkfs.fat -F32 -n boot /dev/DISKp1
mkswap -L swap /dev/DISKp2
mkfs.ext4 -L nixos /dev/DISKp3

# Mount
mount /dev/DISKp3 /mnt
mount --mkdir /dev/DISKp1 /mnt/boot
swapon /dev/DISKp2

# Copy config from read-only ISO
cp -r /iso/etc/nixos-config /tmp/nixos-config

# Generate hardware config and install
nixos-generate-config --root /mnt --show-hardware-config \
  > /tmp/nixos-config/modules/hosts/<hostname>/_hardware-configuration.nix

nixos-install --flake /tmp/nixos-config#<hostname> --no-channel-copy
# Add --option substitute false to force fully offline install (no internet)

# Set user password
nixos-enter --root /mnt -c 'passwd chek'

reboot
```

### Install: Dual Boot (Windows + NixOS)

Shrink Windows partition first (in Windows Disk Management), then boot from USB:

```bash
lsblk

# Create NixOS partitions in free space (keep existing EFI!)
parted /dev/DISK mkpart swap linux-swap <start> <start+4G>
parted /dev/DISK mkpart nixos ext4 <start+4G> 100%

mkswap -L swap /dev/DISKpX
mkfs.ext4 -L nixos /dev/DISKpY

# Mount (use existing Windows EFI partition)
mount /dev/DISKpY /mnt
mount --mkdir /dev/DISKp1 /mnt/boot    # existing EFI
swapon /dev/DISKpX

# Copy config from read-only ISO
cp -r /iso/etc/nixos-config /tmp/nixos-config

# Generate hardware config and install
nixos-generate-config --root /mnt --show-hardware-config \
  > /tmp/nixos-config/modules/hosts/<hostname>/_hardware-configuration.nix

nixos-install --flake /tmp/nixos-config#<hostname> --no-channel-copy
# Add --option substitute false to force fully offline install (no internet)
nixos-enter --root /mnt -c 'passwd chek'

reboot
```

> systemd-boot will automatically detect Windows Boot Manager on the EFI partition.

## Inspiration

- [Doc-Steve/dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)
- [onatustun/nix-config](https://github.com/onatustun/nix-config)
- [TheMaxMur/NixOS-Configuration](https://github.com/TheMaxMur/NixOS-Configuration)
- [khaneliman/khanelinix](https://github.com/khaneliman/khanelinix)
