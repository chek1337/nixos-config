{ config, ... }:
let
  hmMod = name: config.flake.modules.homeManager.${name} or { };
  modules = [
    "kitty"
    "alacritty"
    # "wezterm"
  ];
in
{
  flake.modules.homeManager.terminals = {
    imports = map hmMod modules;
  };
}
