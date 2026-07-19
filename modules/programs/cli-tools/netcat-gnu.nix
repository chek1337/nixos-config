{ ... }:
{
  flake.modules.homeManager.netcat-gnu =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.netcat-gnu ];
    };
}
