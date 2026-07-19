{ ... }:
{
  flake.modules.homeManager.playerctl =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.playerctl ];
    };
}
