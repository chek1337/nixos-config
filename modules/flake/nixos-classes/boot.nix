{ ... }:
{
  flake.modules.nixos.nixos =
    { pkgs, ... }:
    {
      boot = {
        # kernelPackages = pkgs.linuxPackages_latest;
        loader = {
          systemd-boot.enable = true;
          systemd-boot.configurationLimit = 5;
          systemd-boot.sortKey = "z-nixos";
          efi.canTouchEfiVariables = true;
        };
      };
    };
}
