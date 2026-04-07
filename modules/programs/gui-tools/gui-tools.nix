{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "gui-browsers"
    "gui-code-editors"
    "telegram"
    "nautilus"
    "spicetify"
    "discord"
    "libreoffice"
    "zathura"
    "imv"
    "mpv"
    "qbittorrent"
    "obs"
    "pinta"
  ];
in
{
  flake.modules.nixos.gui-tools = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.gui-tools = {
    imports = map hmMod modules;
  };
}
