{ config, ... }:
let
  inherit (config.flake.lib) hmMod;
  modules = [
    "browser-bookmarks"
    "firefox-common"
    "firefox"
    "qutebrowser"
    "librewolf"
    "zen"
    "yandex-browser"
  ];
in
{
  flake.modules.homeManager.gui-browsers = {
    imports = map hmMod modules;
  };
}
