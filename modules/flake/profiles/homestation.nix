{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "workstation"
    "gaming"
    "waydroid"
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
