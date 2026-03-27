{ ... }:
{
  flake.modules.homeManager.obs =
    { pkgs, ... }:
    {
      programs.obs-studio = {
        enable = true;
      };
    };
}
