{ config, ... }:
let
  inherit (config.flake.lib) hmMod;
  modules = [
    "eza"
    "yazi"
    "git"
    "gh"
    "tmux"
    "television"
    "nix-search-tv"
    "zellij"
    "nvim"
    "nvf"
    "zoxide"
    "trash-cli"
    "btop"
    "bat"
    "soundscope"
    "cmus"
    "rice"
    "wallpaper-colorizer"
    "network-managing"
  ];
in
{
  flake.modules.homeManager.cli-tools = {
    imports = map hmMod modules;
  };
}
