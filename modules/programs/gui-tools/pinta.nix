{
  flake.modules.homeManager.pinta =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.pinta ];
    };
}
