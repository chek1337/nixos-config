{
  flake.modules.homeManager.zathura =
    { pkgs, ... }:
    {
      programs.zathura.enable = true;
    };
}
