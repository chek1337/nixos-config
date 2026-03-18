{ config, ... }:
let
  flakeConfig = config;
  hostname = "wsl-asuslaptop";
  username = "chek";
  modules = [
    "nord"
    "zsh"
    "cli-tools"
    "python-dev"
    "wsl-nvidia"
    "sops"
    "vopono"

    "docker"
    "kitty"
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
