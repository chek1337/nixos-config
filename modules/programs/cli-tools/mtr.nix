{ ... }:
{
  flake.modules.homeManager.mtr =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.mtr ];
    };
}
