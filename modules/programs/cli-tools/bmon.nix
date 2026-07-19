{ ... }:
{
  flake.modules.homeManager.bmon =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.bmon ];
    };
}
