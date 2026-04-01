{ ... }:
{
  flake.modules.homeManager.protonup =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.protonup-qt ];
    };
}
