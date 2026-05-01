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
    # grayscale-{dark,light} в nvim = кастомная ilyasyoy-monochrome
    grayscale-dark = import ./ilyasyoy-monochrome {
      inherit pkgs;
      background = "dark";
    };
    grayscale-light = import ./ilyasyoy-monochrome {
      inherit pkgs;
      background = "light";
    };
  };

  theme = themes.${colorScheme} or null;
in
{
  vim.extraPlugins = lib.optionalAttrs (theme != null) { colorscheme = theme; };
}
