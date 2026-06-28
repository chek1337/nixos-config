# Offline Installation (ISO)

Build an ISO containing all packages for offline NixOS installation on any x86_64 machine.

## Build ISO

```bash
just iso <hostname>
```

Write to USB:

```bash
dd if=result-iso/iso/*.iso of=/dev/sdX bs=4M status=progress
```

## Identify target disk

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

## Flake configuration path

The ISO mounts at `/iso`. The flake is available at:

```
/iso/etc/nixos-config
```

> The ISO filesystem is **read-only**. Copy the config to a writable location before making changes:
>
> ```bash
> cp -r /iso/etc/nixos-config /tmp/nixos-config
> ```
>
> All commands below use `/tmp/nixos-config` as the working copy.

## Install: Clean Disk

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

# Generate hardware config
nixos-generate-config --root /mnt --show-hardware-config \
  > /tmp/nixos-config/modules/hosts/<hostname>/_hardware-configuration.nix

nixos-install --flake /tmp/nixos-config#<hostname> --no-channel-copy
# Add --option substitute false to force fully offline install (no internet)

# Set user password
nixos-enter --root /mnt -c 'passwd chek'

reboot
```

## Install: Dual Boot (Windows + NixOS)

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

# Generate hardware config
nixos-generate-config --root /mnt --show-hardware-config \
  > /tmp/nixos-config/modules/hosts/<hostname>/_hardware-configuration.nix

nixos-install --flake /tmp/nixos-config#<hostname> --no-channel-copy
# Add --option substitute false to force fully offline install (no internet)
nixos-enter --root /mnt -c 'passwd chek'

reboot
```

> systemd-boot will automatically detect Windows Boot Manager on the EFI partition.
