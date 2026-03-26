{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
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
