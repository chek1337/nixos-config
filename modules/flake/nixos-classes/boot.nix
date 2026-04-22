{ inputs, ... }:
{
  flake.modules.nixos.nixos =
    { pkgs, ... }:
    {
      imports = [ inputs.elegant-grub2-themes.nixosModules.default ];

      stylix.targets.grub.enable = false;
      boot = {
        kernelPackages = pkgs.linuxPackages_latest;
        loader = {
          grub = {
            enable = true;
            devices = [ "nodev" ];
            efiSupport = true;
            useOSProber = true;
            # configurationLimit = 20;
          };
          efi.canTouchEfiVariables = true;
          elegant-grub2-theme = {
            enable = true;
            theme = "forest";
            type = "float";
            side = "right";
            color = "dark";
            screen = "1080p";
            logo = "system";
          };
        };
      };
    };
}
