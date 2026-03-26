{ config, ... }:
let
  inherit (config.flake.lib) hmMod;
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
