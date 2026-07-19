{ ... }:
{
  flake.modules.homeManager.iftop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.iftop ];
    };
}
