{ ... }:
{
  flake.modules.homeManager.qbittorrent =
    { pkgs-stable, ... }:
    {
      home.packages = [ pkgs-stable.qbittorrent ];
    };
}
