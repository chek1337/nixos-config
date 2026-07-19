{ ... }:
{
  flake.modules.homeManager.whois =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.whois ];
    };
}
