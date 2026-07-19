{ ... }:
{
  flake.modules.homeManager.wget =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.wget ];
    };
}
