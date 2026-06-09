{ ... }:
{
  flake.modules.homeManager.impression =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.impression ];
    };
}
