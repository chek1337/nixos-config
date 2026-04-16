{ ... }:
{
  flake.modules.nixos.nixos =
    { pkgs, ... }:
    {
      boot = {
        kernelPackages = pkgs.linuxPackages_latest;
        loader = {
          systemd-boot = {
            enable = true;
            configurationLimit = 3;
          };
          efi.canTouchEfiVariables = true;
        };
      };
    };
}
