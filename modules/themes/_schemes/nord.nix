{ self, pkgs }:
{
  image = self + "/assets/nord2.png";
  icons = {
    package = pkgs.nordzy-icon-theme;
    dark = "Nordzy-dark";
    light = "Nordzy";
  };
}
