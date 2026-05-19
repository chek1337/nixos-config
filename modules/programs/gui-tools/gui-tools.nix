{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "gui-browsers"
    "gui-code-editors"
    "telegram"
    "nautilus"
    "spicetify"
    "libreoffice"
    "zathura"
    "imv"
    "mpv"
    "obsidian"
    "wine"
    # "zoom"
    # "hibiki"
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
