{ ... }:
{
  flake.modules.homeManager.obs =
    { pkgs-stable, ... }:
    {
      programs.obs-studio = {
        enable = true;
        package = pkgs-stable.obs-studio;
      };
    };
}
