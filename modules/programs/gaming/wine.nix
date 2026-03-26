{ pkgs, ... }:
{
  flake.modules.nixos.wine = {
    environment.systemPackages = with pkgs; [
      wineWowPackages.stable
      winetricks
    ];
  };
}
