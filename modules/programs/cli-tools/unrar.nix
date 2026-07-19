{ ... }:
{
  flake.modules.homeManager.unrar =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.unrar ];
    };
}
