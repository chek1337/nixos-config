{ config, ... }:
let
  inherit (config.flake.lib) hmMod;
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
