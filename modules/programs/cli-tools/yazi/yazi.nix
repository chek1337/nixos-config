{ config, ... }:
let
  hmMods = config.flake.modules.homeManager;
  submoduleNames = [
    "yazi-core"
    "yazi-plugins"
    "yazi-tv-sel"
    "yazi-tv-grep-router"
    "yazi-previewers"
    "yazi-keybindings"
  ];
  pick = mods: map (n: mods.${n}) submoduleNames;
in
{
  flake.modules.homeManager.yazi =
    { ... }:
    {
      imports = pick hmMods;
    };
}
