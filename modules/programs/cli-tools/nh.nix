{ ... }:
{
  flake.modules.homeManager.nh =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nh ];
    };
}
