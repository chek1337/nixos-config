{ config, ... }:
let
  flakeConfig = config;
  hostname = "generic";
  username = "chek";
  theme = "nord";
  shell = "zsh";
  modules = [
    "cli-tools"
    "gui-tools"
    "wayland-common"
    "niri"
    "terminals"
    "desktop-env"
    "sops"

    "wireguard"
    "wireproxy"
    "zapret"
    "vopono"

    "noctalia"

    "docker"
    "wireshark"
    "claude-code"
    "python-dev"
  ];
in
{
  flake = {
    nixosConfigurations.${hostname} = flakeConfig.flake.lib.mkSystems.linux username hostname;
    nixosConfigurations."iso-${hostname}" = flakeConfig.flake.lib.mkSystems.iso username hostname;
    modules.nixos."hosts/${hostname}" = {
      imports =
        (flakeConfig.flake.lib.loadNixosAndHmModuleForUser flakeConfig modules)
        ++ [ ./_hardware-configuration.nix ]
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
