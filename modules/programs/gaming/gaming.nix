{ config, ... }:
let
  nixosMod = name: config.flake.modules.nixos.${name} or { };
  modules = [
    "steam"
  ];
in
{
  flake.modules.nixos.gaming = {
    imports = map nixosMod modules;
  };
}
