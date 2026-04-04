{ self, pkgs }:
{
  image = self + "/assets/catppuccin-mocha.jpg";
  icons = {
    package = pkgs.catppuccin-papirus-folders;
    dark = "Papirus-Dark";
    light = "Papirus";
  };
}
