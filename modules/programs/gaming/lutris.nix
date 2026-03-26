{ pkgs, ... }:
{
  flake.modules.homeManager.lutris = {
    programs.lutris = {
      enable = true;
      extraPackages = with pkgs; [
        mangohud
        winetricks
        gamescope
        gamemode
      ];
    };
  };
}
