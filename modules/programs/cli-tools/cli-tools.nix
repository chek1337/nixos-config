{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "eza"
    "yazi"
    "git"
    "hunk"
    "gh"
    "tmux"
    "television"
    "nix-search-tv"
    # "zellij"
    "nixvim"
    "zoxide"
    "trash-cli"
    "btop"
    "bat"
    "mermaid"
    # "soundscope"
    # "cmus"
    # "rice"
    # "wallpaper-colorizer"
    "network-managing"
  ];
in
{
  flake.modules.nixos.cli-tools = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.cli-tools = {
    imports = map hmMod modules;
  };
}
