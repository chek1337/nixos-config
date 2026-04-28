{ ... }:
{
  flake.modules.homeManager.lutris =
    { pkgs-stable, ... }:
    {
      programs.lutris = {
        enable = true;
        extraPackages = with pkgs-stable; [
          mangohud
          winetricks
          gamescope
          gamemode
        ];
      };
    };
}
