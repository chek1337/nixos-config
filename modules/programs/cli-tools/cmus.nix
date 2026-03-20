{ ... }:
{
  flake.modules.homeManager.cmus =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.cmus ];
    };
}
