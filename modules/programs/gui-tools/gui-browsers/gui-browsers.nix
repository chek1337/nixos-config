{ config, ... }:
let
  inherit (config.flake.lib) hmMod;
  modules = [
    "browser-bookmarks"
    "browser-extensions"
    "browser-search"
    "firefox-common"
    "firefox"
    "qutebrowser"
    "librewolf"
    "zen"
    "chromium-common"
    "chromium"
    "yandex-browser"
  ];
in
{
  flake.modules.homeManager.gui-browsers = {
    imports = map hmMod modules;
  };
}
