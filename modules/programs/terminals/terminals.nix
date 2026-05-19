{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "kitty"
    "alacritty"
    "ghostty"
    # "wezterm"
  ];
in
{
  flake.modules.nixos.terminals = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.terminals = {
    imports = map hmMod modules;
  };
}
