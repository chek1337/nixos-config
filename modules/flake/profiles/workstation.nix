{ config, ... }:
let
  nixosMod = name: config.flake.modules.nixos.${name} or { };
  hmMod = name: config.flake.modules.homeManager.${name} or { };
  modules = [
    "virtualization"
    "mail"
    "pttkey"
    "usb-automount"
    "zmkbatx"
  ];
in
{
  flake.modules.nixos.workstation = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.workstation = {
    imports = map hmMod modules;
  };
}
