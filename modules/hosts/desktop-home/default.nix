{ config, ... }:
let
  flakeConfig = config;
  hostname = "desktop-home";
  username = "chek";
  modules = [
    "nord"
    "zsh"
    "cli-tools"
    "gui-tools"
    "desktop-base"
    "niri"
    "terminals"
    "desktop-env"

    "networking"
    "zmkbatx"

    "noctalia"

    "docker"
    "virtualization"
    "wireshark"
    "claude-code"
    "direnv"
    "python-dev"
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
