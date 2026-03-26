{ ... }:
{
  flake.modules.homeManager.lutris =
    { pkgs, ... }:
    {
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
