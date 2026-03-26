{ config, ... }:
let
  hmMod = name: config.flake.modules.homeManager.${name} or { };
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
  ];
in
{
  flake.modules.nixos.gui-tools = { };

  flake.modules.homeManager.gui-tools = {
    imports = map hmMod modules;
  };
}
