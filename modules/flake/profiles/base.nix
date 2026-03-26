{ config, ... }:
let
  nixosMod = name: config.flake.modules.nixos.${name} or { };
  hmMod = name: config.flake.modules.homeManager.${name} or { };
  modules = [
    "nord"
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
