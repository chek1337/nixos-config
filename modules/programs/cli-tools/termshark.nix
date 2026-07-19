{ ... }:
{
  flake.modules.homeManager.termshark =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.termshark ];
    };
}
