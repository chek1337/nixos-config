{ ... }:
{
  flake.modules.homeManager.cmus =
    { pkgs-stable, ... }:
    {
      home.packages = [ pkgs-stable.cmus ];
    };
}
