{
  flake.modules.homeManager.zathura =
    { pkgs-stable, ... }:
    {
      programs.zathura.enable = true;
    };
}
