{ config, ... }:
let
  inherit (config.flake.lib) nixosMod;
  modules = [
    "sops"
    "bluetooth"
    "power"
    "wayland-common"
    "x11-compat"
  ];
in
{
  flake.modules.nixos.desktop-base = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.desktop-base = { };
}
