{ ... }:
{
  flake.modules.homeManager.opencode =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.opencode ];
    };
}
