# in progress
{ config, ... }:
let
  nixosMods = config.flake.modules.nixos;
  submoduleNames = [
    "remote-access-openssh"
    "remote-access-sunshine"
    "remote-access-moonlight"
  ];
  pick = mods: map (n: mods.${n}) submoduleNames;
in
{
  flake.modules.nixos.remote-access = {
    imports = pick nixosMods;
  };
}
