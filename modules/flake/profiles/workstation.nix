{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "virtualization"
    "mail"
    # "pttkey"
    "usb-automount"
    # "zmkbatx"
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
