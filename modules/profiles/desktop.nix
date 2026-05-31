{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "base"
    "gui-tools"
    "desktop-base"
    "greetd"
    "niri"
    "noctalia"
    "rice"
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
