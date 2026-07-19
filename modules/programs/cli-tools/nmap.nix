{ ... }:
{
  flake.modules.homeManager.nmap =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nmap ];
    };
}
