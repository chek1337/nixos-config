{ ... }:
{
  flake.modules.homeManager.dig =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.dig ];
    };
}
