{ config, ... }:
let
  inherit (config.flake.lib) hmMod;
  modules = [
    "kitty"
    "alacritty"
    "ghostty"
    # "wezterm"
  ];
in
{
  flake.modules.homeManager.terminals = {
    imports = map hmMod modules;
  };
}
