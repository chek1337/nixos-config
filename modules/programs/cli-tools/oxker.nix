{ ... }:
{
  flake.modules.homeManager.oxker =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.oxker ];
    };
}
