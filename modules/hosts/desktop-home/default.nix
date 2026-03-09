{ config, ... }:
let
  flakeConfig = config;
  theme = "nord";
  shell = "zsh";
  modules = [
    "cli-tools"
    "gui-tools"
    "wayland-common"
    "niri"
    "terminals"
    "desktop-env"
    "bluetooth"
    "sops"
    "wireguard"
    "wireproxy"
    "noctalia"
  ];
in
{
  flake = {
    nixosConfigurations.desktop-home = flakeConfig.flake.lib.mkSystems.linux "desktop-home";
    modules.nixos."hosts/desktop-home" = {
      imports =
        (flakeConfig.flake.lib.loadNixosAndHmModuleForUser flakeConfig modules)
        ++ [ ./_hardware-configuration.nix ]
        ++ [ flakeConfig.flake.modules.nixos.${theme} ]
        ++ [ flakeConfig.flake.modules.nixos.${shell} ];
    };
    modules.homeManager."hosts/desktop-home" = {
      imports = [
        flakeConfig.flake.modules.homeManager.${theme}
        flakeConfig.flake.modules.homeManager.${shell}
      ];
    };
  };
}
