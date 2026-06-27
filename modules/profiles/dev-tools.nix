{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "direnv"
    "claude-code"
    "claude-squad"
    "codex"
    "opencode"
    "gemini-cli"
    "python-dev"
    # "ollama"
  ];
in
{
  flake.modules.nixos.dev-tools = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.dev-tools = {
    imports = map hmMod modules;
  };
}
