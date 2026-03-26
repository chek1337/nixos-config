{ config, ... }:
let
  hmMod = name: config.flake.modules.homeManager.${name} or { };
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
