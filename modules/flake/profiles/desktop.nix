{ config, ... }:
let
  nixosMod = name: config.flake.modules.nixos.${name} or { };
  hmMod = name: config.flake.modules.homeManager.${name} or { };
  modules = [
    "base"
    "gui-tools"
    "desktop-base"
    "niri"
    "noctalia"
    "wireshark"
  ];
in
{
  flake.modules.nixos.desktop = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.desktop = {
    imports = map hmMod modules;
  };
}
