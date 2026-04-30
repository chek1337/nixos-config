{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "kdenlive"
    "obs"
    "image-editors"
    "discord"
    "qbittorrent"
  ];
in
{
  flake.modules.nixos.home-extras = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.home-extras = {
    imports = map hmMod modules;
  };
}
