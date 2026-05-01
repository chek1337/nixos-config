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
    grayscale-dark = import ./grayscale-dark { inherit pkgs; };
    grayscale-light = import ./grayscale-light { inherit pkgs; };
    ilyasyoy-monochrome = import ./ilyasyoy-monochrome { inherit pkgs; };
  };

  theme = themes.${colorScheme} or null;
in
{
  vim.extraPlugins = lib.optionalAttrs (theme != null) { colorscheme = theme; };
}
