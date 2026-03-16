{ config, ... }:
let
  flakeConfig = config;
  hostname = "desktop-home";
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
    "bluetooth"
    "sops"

    "wireguard"
    "wireproxy"
    "zapret"
    "vopono"
    "zmkbatx"

    "noctalia"

    "docker"
    "wireshark"
    "claude-code"

    "power"
  ];
in
{
  flake = {
    nixosConfigurations.${hostname} = flakeConfig.flake.lib.mkSystems.linux username hostname;
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
