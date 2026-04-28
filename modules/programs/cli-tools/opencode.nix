{ ... }:
{
  flake.modules.homeManager.opencode =
    { pkgs-stable, ... }:
    {
      home.packages = [ pkgs-stable.opencode ];
    };
}
