{ config, ... }:
let
  flakeConfig = config;
  hostname = "wsl-asuslaptop";
  username = "chek";
  shell = "zsh";
  theme = "nord";
  modules = [
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
      imports =
        (flakeConfig.flake.lib.loadNixosAndHmModuleForUser flakeConfig modules)
        ++ [ flakeConfig.flake.modules.nixos.${theme} ]
        ++ [ flakeConfig.flake.modules.nixos.${shell} ];
    };
    modules.homeManager."hosts/${hostname}" = {
      imports = [
        flakeConfig.flake.modules.homeManager.${theme}
        flakeConfig.flake.modules.homeManager.${shell}
      ];
    };
  };
}
