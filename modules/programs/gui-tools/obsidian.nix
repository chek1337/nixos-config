{ ... }:
{
  flake.modules.homeManager.obsidian =
    { pkgs, ... }:
    {
      programs.obsidian = {
        enable = true;
      };
    };
}
