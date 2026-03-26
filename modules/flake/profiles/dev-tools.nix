{ config, ... }:
let
  nixosMod = name: config.flake.modules.nixos.${name} or { };
  hmMod = name: config.flake.modules.homeManager.${name} or { };
  modules = [
    "claude-code"
    "direnv"
    "python-dev"
  ];
in
{
  flake.modules.nixos.dev-tools = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.dev-tools = {
    imports = map hmMod modules;
  };
}
