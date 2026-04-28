{ ... }:
{
  flake.modules.homeManager.lutris =
    { pkgs-stable, ... }:
    {
      programs.lutris = {
        enable = true;
        # Lutris и его FHS-зависимости держим на stable: совпадает с
        # extraPackages ниже и обходит i686 openldap test failure из
        # nixpkgs-unstable (test017-syncreplication-refresh).
        package = pkgs-stable.lutris;
        extraPackages = with pkgs-stable; [
          mangohud
          winetricks
          gamescope
          gamemode
        ];
      };
    };
}
