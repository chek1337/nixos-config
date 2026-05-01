{ config, inputs, ... }:
let
  flakeConfig = config;
  hostname = "desktop-work";
  username = "chek";
  modules = [
    "desktop"
    "workstation"
    "networking"
  ];
  sharedSettings = {
    isLaptop = true;
    hasBluetooth = true;
    wireguardConfigName = "wireguard-laptop-asus";
    colorScheme = "catppuccin-mocha";
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
        inputs.nixos-hardware.nixosModules.asus-fa507nv
        ./_hardware-configuration.nix
      ];

      settings = sharedSettings;
    };
    modules.homeManager."hosts/${hostname}" = {
      imports = flakeConfig.flake.lib.loadHmModules modules;

      settings = sharedSettings;

      services.niri.outputs.eDP-1 = {
        mode = "1920x1080@144.063";
        variableRefreshRate = "on-demand";
      };
      services.pttkey.bindings = {
        mouse = {
          keys = [ "BTN_EXTRA" ];
          devicePath = "/dev/input/event1";
        };
        kbd = {
          keys = [ "KEY_F13" ];
        };
      };
    };
  };
}
