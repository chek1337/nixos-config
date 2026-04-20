{ config, inputs, ... }:
let
  flakeConfig = config;
  hostname = "laptop-kvadra";
  username = "daniil";
  modules = [
    "desktop"
    "homestation"
    "networking"
  ];
  sharedSettings = {
    isLaptop = true;
    hasBluetooth = true;
    wireguardConfigName = "wireguard-laptop-kvadra";
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

      # swapDevices = [
      #   {
      #     device = "/var/lib/swapfile";
      #     size = 16 * 1024; # 16 GiB
      #   }
      # ];
    };
    modules.homeManager."hosts/${hostname}" = {
      imports = flakeConfig.flake.lib.loadHmModules modules;

      settings = sharedSettings;

      # services.niri.outputs.eDP-2 = {
      #   mode = "1920x1080@144.063";
      #   variableRefreshRate = "on-demand";
      # };

      # I like use push-to-talk btw
      # services.pttkey.bindings = {
      #   mouse = {
      #     keys = [ "BTN_EXTRA" ];
      #     devicePath = "/dev/input/event6";
      #   };
      #   kbd = {
      #     keys = [ "KEY_F13" ];
      #   };
      # };
    };
  };
}
