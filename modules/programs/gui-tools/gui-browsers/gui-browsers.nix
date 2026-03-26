{ config, ... }:
let
  inherit (config.flake.lib) hmMod;
  modules = [
    # "firefox"
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
