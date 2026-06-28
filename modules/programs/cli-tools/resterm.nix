{ ... }:
{
  flake.modules.homeManager.resterm =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.resterm ];
    };
}
