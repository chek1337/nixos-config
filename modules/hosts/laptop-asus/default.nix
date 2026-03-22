{ config, inputs, ... }:
let
  flakeConfig = config;
  hostname = "laptop-asus";
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
    "aerc"
    "pttkey"
    "usb-automount"
    "asus-power"
    "gaming"
  ];
in
{
  flake = {
    nixosConfigurations.${hostname} = flakeConfig.flake.lib.mkSystems.linux username hostname;
    nixosConfigurations."iso-${hostname}" = flakeConfig.flake.lib.mkSystems.iso username hostname;
    modules.nixos."hosts/${hostname}" = {
      imports = (flakeConfig.flake.lib.loadNixosAndHmModuleForUser flakeConfig modules) ++ [
        inputs.nixos-hardware.nixosModules.asus-fa507nv
        ./_hardware-configuration.nix
      ];

      settings.isLaptop = true;
    };
    modules.homeManager."hosts/${hostname}" = {
      services.pttkey.bindings = {
        mouse = {
          keys = [ "BTN_EXTRA" ];
          devicePath = "/dev/input/event6";
        };
        kbd = {
          keys = [ "KEY_F13" ];
        };
      };
    };
  };
}
