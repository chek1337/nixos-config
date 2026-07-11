{ ... }:
{
  flake.modules.homeManager.openspec =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.openspec ];
    };
}
