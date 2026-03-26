{ config, ... }:
let
  nixosMod = name: config.flake.modules.nixos.${name} or { };
  hmMod = name: config.flake.modules.homeManager.${name} or { };
  modules = [
    "workstation"
    "gaming"
  ];
in
{
  flake.modules.nixos.homestation = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.homestation = {
    imports = map hmMod modules;
  };
}
