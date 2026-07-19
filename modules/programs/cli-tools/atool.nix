{ ... }:
{
  flake.modules.homeManager.atool =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.atool ];
    };
}
