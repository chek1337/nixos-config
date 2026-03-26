{ config, ... }:
let
  hmMod = name: config.flake.modules.homeManager.${name} or { };
  modules = [
    "vscode"
    "sublime"
  ];
in
{
  flake.modules.homeManager.gui-code-editors = {
    imports = map hmMod modules;
  };
}
