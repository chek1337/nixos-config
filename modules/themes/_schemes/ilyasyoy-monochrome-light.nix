{ self, pkgs }:
{
  image = self + "/assets/dark-light.jpg";
  icons = {
    package = pkgs.papirus-icon-theme;
    dark = "Papirus-Dark";
    light = "Papirus-Light";
  };

  # Палитра ilyasyoy-monochrome (light): инвертированная монохромная шкала
  # bg→fg + затемнённые акценты для читаемости на светлом фоне.
  base16 = {
    scheme = "Ilyasyoy Monochrome Light";
    author = "ilyasyoy";
    variant = "light";

    base00 = "eeeeee"; # bg
    base01 = "e4e4e4"; # subtle (status bar bg)
    base02 = "d7d7d7"; # elevated (selection bg)
    base03 = "cccccc"; # noise
    base04 = "626262"; # muted (comments)
    base05 = "1a1a1a"; # near-fg
    base06 = "0a0a0a";
    base07 = "000000"; # fg

    base08 = "ff005f"; # red — error
    base09 = "ffaf00"; # orange — visual
    base0A = "af8700"; # yellow (затемнён для светлого bg)
    base0B = "416241"; # green — diff add (lua dark green)
    base0C = "00afff"; # cyan — search
    base0D = "005faf"; # blue (затемнён)
    base0E = "5f5f87"; # purple — cursor (затемнён)
    base0F = "722529"; # brown — diff remove (lua dark red)
  };
}
