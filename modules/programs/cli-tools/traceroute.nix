{ ... }:
{
  flake.modules.homeManager.traceroute =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.traceroute ];
    };
}
