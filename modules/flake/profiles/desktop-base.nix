{ config, ... }:
let
  inherit (config.flake.lib) nixosMod;
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
