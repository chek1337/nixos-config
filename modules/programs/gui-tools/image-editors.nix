{
  flake.modules.homeManager.image-editors =
    { pkgs, ... }:
    {
      home.packages = [
        # pkgs.pinta
        # pkgs.krita
        pkgs.gimp
      ];
    };
}
