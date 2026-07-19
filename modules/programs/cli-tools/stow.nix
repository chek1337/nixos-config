{ ... }:
{
  flake.modules.homeManager.stow =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.stow ];
    };
}
