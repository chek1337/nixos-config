{ config, ... }:
let
  flakeConfig = config;
  hostname = "desktop-home";
  username = "chek";
  modules = [
    "desktop"
    "homestation"
    "networking"
    "remote-access"
  ];
  sharedSettings = {
    hasBluetooth = true;
    wireguardConfigName = "wireguard-desktop-home";
    colorScheme = "catppuccin-mocha";

    enableRemoteSsh = true;
    enableRemoteDesktop = true;
    remoteSshAuthorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA213f/P1prxD2ImqqW6goD6iBsHH8E5HvEOf+R/dkk8 chek@wsl-asuslaptop"
    ];
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

      services.niri.blur.enable = false;

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
