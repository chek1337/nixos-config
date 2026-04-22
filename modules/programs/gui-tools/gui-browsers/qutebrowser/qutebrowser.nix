{ config, ... }:
let
  hmMods = config.flake.modules.homeManager;
  submoduleNames = [
    "qutebrowser-core"
    "qutebrowser-fuzzel"
  ];
  pick = mods: map (n: mods.${n}) submoduleNames;
in
{
  flake.modules.homeManager.qutebrowser =
    { ... }:
    {
      programs.qutebrowser.enable = true;

      imports = pick hmMods;
    };
}
