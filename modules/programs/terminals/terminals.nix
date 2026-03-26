{ config, ... }:
let
  inherit (config.flake.lib) hmMod;
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
