{ ... }:
{
  flake.modules.nixos.nixos =
    { pkgs, config, ... }:
    {
      boot = {
        kernelPackages = pkgs.${"linuxPackages_" + config.settings.kernel};
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
