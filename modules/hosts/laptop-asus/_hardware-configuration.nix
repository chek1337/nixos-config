# TODO: Generate on the actual laptop with:
#   nixos-generate-config --show-hardware-config > _hardware-configuration.nix
{ ... }:
{
  # Placeholder — replace with actual hardware configuration
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
