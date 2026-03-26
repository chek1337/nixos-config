{ config, ... }:
let
  inherit (config.flake.lib) hmMod;
  modules = [
    # "browsh"
    # "firefox"
    "w3m"
  ];
in
{
  flake.modules.homeManager.cli-browsers = {
    imports = map hmMod modules;
  };
}
