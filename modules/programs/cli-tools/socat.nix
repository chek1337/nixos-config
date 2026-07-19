{ ... }:
{
  flake.modules.homeManager.socat =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.socat ];
    };
}
