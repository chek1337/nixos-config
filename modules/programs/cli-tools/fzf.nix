{ ... }:
{
  flake.modules.homeManager.fzf =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.fzf ];
    };
}
