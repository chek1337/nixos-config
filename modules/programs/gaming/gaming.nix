{ config, ... }:
let
  inherit (config.flake.lib) nixosMod;
  modules = [
    "steam"
  ];
in
{
  flake.modules.nixos.gaming = {
    imports = map nixosMod modules;
  };
}
