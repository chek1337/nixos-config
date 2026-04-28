{
  flake.modules.homeManager.libreoffice =
    { pkgs-stable, ... }:
    {
      home.packages = [ pkgs-stable.libreoffice-fresh ];
    };
}
