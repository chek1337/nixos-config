{ ... }:
{
  flake.modules.nixos.nixos =
    { pkgs, ... }:
    {
      boot = {
        # kernelPackages = pkgs.linuxPackages_latest;
        loader = {
          systemd-boot.enable = true;
          systemd-boot.extraEntries = {
            "00-windows.conf" = ''
              title Windows
              efi /EFI/Microsoft/Boot/bootmgfw.efi
            '';
          };
          efi.canTouchEfiVariables = true;
        };
      };
    };
}
