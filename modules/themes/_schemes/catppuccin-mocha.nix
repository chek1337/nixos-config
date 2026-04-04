{ self, pkgs }:
{
  image = self + "/assets/nord2.png"; # TODO: заменить на catppuccin-обои
  icons = {
    package = pkgs.catppuccin-papirus-folders;
    dark = "Papirus-Dark";
    light = "Papirus";
  };
}
