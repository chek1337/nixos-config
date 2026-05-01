{ self, pkgs }:
{
  image = self + "/assets/dark-light.jpg";
  icons = {
    package = pkgs.papirus-icon-theme;
    dark = "Papirus-Dark";
    light = "Papirus-Light";
  };
}
