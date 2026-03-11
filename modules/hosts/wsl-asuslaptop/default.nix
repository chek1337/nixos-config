{ config, ... }:
let
  flakeConfig = config;
  shell = "zsh";
  theme = "nord";
  modules = [
    "cli-tools"
    "python-dev"
    "wsl-nvidia"
    "sops"

    "fixes"
  ];
in
{
  flake = {
    nixosConfigurations.wsl-asuslaptop = flakeConfig.flake.lib.mkSystems.wsl "wsl-asuslaptop";
    modules.nixos."hosts/wsl-asuslaptop" = {
      imports =
        (flakeConfig.flake.lib.loadNixosAndHmModuleForUser flakeConfig modules)
        ++ [ flakeConfig.flake.modules.nixos.${theme} ]
        ++ [ flakeConfig.flake.modules.nixos.${shell} ];
    };
    modules.homeManager."hosts/wsl-asuslaptop" = {
      imports = [
        flakeConfig.flake.modules.homeManager.${theme}
        flakeConfig.flake.modules.homeManager.${shell}
      ];
    };
  };
}
