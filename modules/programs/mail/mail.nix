{ config, ... }:
let
  nixosMod = name: config.flake.modules.nixos.${name} or { };
  hmMod = name: config.flake.modules.homeManager.${name} or { };
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
