{ ... }:
{
  flake.modules.homeManager.dua =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.dua ];
    };
}
