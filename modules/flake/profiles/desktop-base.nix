{ config, ... }:
let
  nixosMod = name: config.flake.modules.nixos.${name} or { };
  modules = [
    "sops"
    "bluetooth"
    "power"
    "wayland-common"
  ];
in
{
  flake.modules.nixos.desktop-base = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.desktop-base = { };
}
