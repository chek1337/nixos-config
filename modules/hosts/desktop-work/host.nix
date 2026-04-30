{ config, ... }:
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
    isWorkstation = true;
    hasBluetooth = true;
    wireguardConfigName = "wireguard-desktop-work";
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
        ./_hardware-configuration.nix
      ];

      settings = sharedSettings;
    };
    modules.homeManager."hosts/${hostname}" = {
      imports = flakeConfig.flake.lib.loadHmModules modules;

      settings = sharedSettings;

      # services.niri.outputs.* — fill in after install on real hardware.
      # services.pttkey.bindings — fill in for the target machine's input devices.
    };
  };
}
