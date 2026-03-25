{ config, ... }:
let
  flakeConfig = config;
  hostname = "desktop-home";
  username = "chek";
  modules = [
    "nord"
    "zsh"
    "cli-tools"
    "gui-tools"
    "desktop-base"
    "niri"
    "terminals"
    "desktop-env"

    "networking"
    "zmkbatx"

    "noctalia"

    "docker"
    "virtualization"
    "wireshark"
    "claude-code"
    "direnv"
    "python-dev"
    "sops"
    "mail"
    "pttkey"
    "usb-automount"
    "gaming"
  ];
in
{
  flake = {
    nixosConfigurations.${hostname} = flakeConfig.flake.lib.mkSystems.linux username hostname;
    nixosConfigurations."iso-${hostname}" = flakeConfig.flake.lib.mkSystems.iso username hostname;
    modules.nixos."hosts/${hostname}" = {
      imports = (flakeConfig.flake.lib.loadNixosAndHmModuleForUser flakeConfig modules) ++ [
        ./_hardware-configuration.nix
      ];

      settings.wireguardConfigName = "wireguard-desktop-home";
    };
    modules.homeManager."hosts/${hostname}" = {
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
