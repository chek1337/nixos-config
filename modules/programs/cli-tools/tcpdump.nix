{ ... }:
{
  flake.modules.homeManager.tcpdump =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.tcpdump ];
    };
}
