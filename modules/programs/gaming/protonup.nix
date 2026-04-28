{ ... }:
{
  flake.modules.homeManager.protonup =
    { pkgs-stable, ... }:
    {
      home.packages = [ pkgs-stable.protonup-qt ];
    };
}
