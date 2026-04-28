{
  flake.modules.homeManager.kdenlive =
    { pkgs-stable, ... }:
    {
      home.packages = [ pkgs-stable.kdePackages.kdenlive ];
    };
}
