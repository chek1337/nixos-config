{ self, pkgs }:
{
  image = self + "/assets/gruvbox-dark-hard.png";
  icons = {
    package = pkgs.gruvbox-plus-icons;
    dark = "GruvboxPlus";
    light = "GruvboxPlus";
  };
}
