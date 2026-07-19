{ ... }:
{
  flake.modules.homeManager.p7zip =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.p7zip ];
    };
}
