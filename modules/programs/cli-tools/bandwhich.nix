{ ... }:
{
  flake.modules.homeManager.bandwhich =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.bandwhich ];
    };
}
