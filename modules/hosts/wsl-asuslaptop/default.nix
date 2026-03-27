{ config, ... }:
let
  flakeConfig = config;
  hostname = "wsl-asuslaptop";
  username = "chek";
  modules = [
    "base"
    "wsl-nvidia"
    "sops"
    "vopono"
  ];
in
{
  flake = {
    nixosConfigurations.${hostname} = flakeConfig.flake.lib.mkSystems.wsl username hostname;
    homeConfigurations."${username}@${hostname}" =
      flakeConfig.flake.lib.mkHomes.home-wsl username hostname;

    modules.nixos."hosts/${hostname}" = {
      imports = flakeConfig.flake.lib.loadNixosModules modules;
    };
    modules.homeManager."hosts/${hostname}" = {
      imports = flakeConfig.flake.lib.loadHmModules modules;
    };
  };
}
