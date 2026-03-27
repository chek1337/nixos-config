{ ... }:
{
  flake.modules.homeManager.qbittorrent =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ qbittorrent ];
    };
}
