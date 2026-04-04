{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "themes"
    "zsh"
    "cli-tools"
    "dev-tools"
    "docker"
    "terminals"
  ];
in
{
  flake.modules.nixos.base = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.base = {
    imports = map hmMod modules;
  };
}
