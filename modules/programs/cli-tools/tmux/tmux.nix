{ config, ... }:
let
  hmMods = config.flake.modules.homeManager;
  submoduleNames = [
    "tmux-core"
    "tmux-keybindings"
    "tmux-theme"
    "tmux-plugins"
    "tmux-sesh"
    "tmux-tmuxinator"
    "tmux-smart-splits"
  ];
  pick = mods: map (n: mods.${n}) submoduleNames;
in
{
  flake.modules.homeManager.tmux =
    { ... }:
    {
      imports = pick hmMods;
    };
}
