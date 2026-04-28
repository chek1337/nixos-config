{ ... }:
{
  flake.modules.homeManager.discord =
    { pkgs-stable, ... }:
    {
      home.packages = [ pkgs-stable.equibop ];
    };
}
