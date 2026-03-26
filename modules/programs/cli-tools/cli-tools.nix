{ config, ... }:
let
  inherit (config.flake.lib) hmMod;
  modules = [
    "eza"
    "yazi"
    "git"
    "gh"
    "tmux"
    "zellij"
    "nvim"
    "zoxide"
    "trash-cli"
    "btop"
    "bat"
    # "pay-respects"
    "soundscope"
    "cmus"

    "rice"
    "network-managing"
    "cli-browsers"
    "aerc"
  ];
in
{
  flake.modules.homeManager.cli-tools = {
    imports = map hmMod modules;
  };
}
