{ config, ... }:
let
  flakeConfig = config;
  hostname = "desktop-home";
  username = "chek";
  modules = [
    "desktop"
    "homestation"
    "networking"
  ];
  sharedSettings = {
    hasBluetooth = true;
    wireguardConfigName = "wireguard-desktop-home";
    colorScheme = "nord";
  };
in
{
  flake = {
    nixosConfigurations.${hostname} = flakeConfig.flake.lib.mkSystems.linux username hostname;
    nixosConfigurations."iso-${hostname}" = flakeConfig.flake.lib.mkSystems.iso username hostname;
    homeConfigurations."${username}@${hostname}" =
      flakeConfig.flake.lib.mkHomes.home-linux username hostname;

    modules.nixos."hosts/${hostname}" = {
      imports = (flakeConfig.flake.lib.loadNixosModules modules) ++ [
        ./_hardware-configuration.nix
      ];

      settings = sharedSettings;
    };
    modules.homeManager."hosts/${hostname}" = {
      imports = flakeConfig.flake.lib.loadHmModules modules;

      settings = sharedSettings;

      services.niri.outputs.DP-1 = {
        position = {
          x = 0;
          y = 180;
        };
      };
      services.niri.outputs.HDMI-A-1 = {
        mode = "1920x1080@60.000";
        position = {
          x = 1600;
          y = 0;
        };
      };
      services.pttkey.bindings = {
        mouse = {
          keys = [ "BTN_EXTRA" ];
          devicePath = "/dev/input/by-id/usb-E-Signal_USB_Gaming_Mouse-event-mouse";
        };
        kbd = {
          keys = [ "KEY_F13" ];
        };
      };
    };
  };
}
