{
  pkgs,
  lib,
  colorScheme,
  ...
}:
let
  themes = {
    nord = import ./nord { inherit pkgs; };
    catppuccin-mocha = import ./catppuccin-mocha { inherit pkgs; };
    gruvbox-dark-hard = import ./gruvbox-dark-hard { inherit pkgs; };
    ilyasyoy-monochrome-dark = import ./ilyasyoy-monochrome {
      inherit pkgs;
      background = "dark";
    };
    ilyasyoy-monochrome-light = import ./ilyasyoy-monochrome {
      inherit pkgs;
      background = "light";
    };
  };

  theme = themes.${colorScheme} or null;
in
{
  vim.extraPlugins = lib.optionalAttrs (theme != null) { colorscheme = theme; };
}
