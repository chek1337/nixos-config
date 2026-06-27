{ ... }:
{
  flake.modules.homeManager.herdr =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.herdr ];
    };
}
