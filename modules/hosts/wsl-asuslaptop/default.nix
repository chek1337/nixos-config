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
    modules.nixos."hosts/${hostname}" = {
      imports = flakeConfig.flake.lib.loadNixosAndHmModuleForUser flakeConfig modules;
    };
    modules.homeManager."hosts/${hostname}" = { };
  };
}
