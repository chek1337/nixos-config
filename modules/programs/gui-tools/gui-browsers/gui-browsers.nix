{ config, ... }:
let
  hmMod = name: config.flake.modules.homeManager.${name} or { };
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
