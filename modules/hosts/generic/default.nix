{ config, ... }:
let
  flakeConfig = config;
  hostname = "generic";
  username = "chek";
  modules = [
    "desktop"
    "networking"
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
    };
    modules.homeManager."hosts/${hostname}" = { };
  };
}
