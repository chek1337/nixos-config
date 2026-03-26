{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  nixosModules = [
    "email-accounts"
  ];
  hmModules = [
    "email-accounts"
    "aerc"
    "thunderbird"
  ];
in
{
  flake.modules.nixos.mail = {
    imports = map nixosMod nixosModules;
  };

  flake.modules.homeManager.mail = {
    imports = map hmMod hmModules;
  };
}
