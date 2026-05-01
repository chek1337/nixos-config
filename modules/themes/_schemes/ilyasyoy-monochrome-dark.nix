{ self, pkgs }:
{
  image = self + "/assets/dark.png";
  icons = {
    package = pkgs.papirus-icon-theme;
    dark = "Papirus-Dark";
    light = "Papirus-Light";
  };

  # Палитра ilyasyoy-monochrome (dark): монохромные тоны base00..base07 +
  # семантические акценты из lua-палитры (search/visual/error/cursor/diff).
  base16 = {
    scheme = "Ilyasyoy Monochrome Dark";
    author = "ilyasyoy";
    variant = "dark";

    base00 = "000000"; # bg
    base01 = "1c1c1c"; # elevated (status bar bg)
    base02 = "303030"; # subtle (selection bg / cursorline)
    base03 = "707070"; # muted (comments)
    base04 = "9e9e9e";
    base05 = "dadada"; # fg
    base06 = "ebebeb";
    base07 = "ffffff";

    base08 = "ff005f"; # red — error
    base09 = "ffaf00"; # orange — visual
    base0A = "ffaf00"; # yellow
    base0B = "8dda9e"; # green — diff add
    base0C = "00afff"; # cyan — search
    base0D = "00afff"; # blue
    base0E = "8787af"; # purple — cursor
    base0F = "da8d8d"; # brown — diff remove
  };
}
