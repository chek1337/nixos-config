{
  flake.modules.homeManager.image-editors =
    { pkgs-stable, ... }:
    {
      home.packages = [
        # pkgs-stable.pinta
        # pkgs-stable.krita
        pkgs-stable.gimp
      ];
    };
}
