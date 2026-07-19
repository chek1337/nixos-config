{ ... }:
{
  flake.modules.homeManager.pciutils =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.pciutils ];
    };
}
