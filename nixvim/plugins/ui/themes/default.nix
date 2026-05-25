{
  pkgs,
  lib,
  config,
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
in
{
  options.colorScheme = lib.mkOption {
    type = lib.types.str;
    default = "nord";
    description = "Base16 colorscheme name; controls which theme module loads.";
  };

  config = lib.mkMerge (
    lib.mapAttrsToList (
      name: theme:
      lib.mkIf (config.colorScheme == name) {
        extraPlugins = [ theme.package ];
        extraConfigLua = theme.setup;
      }
    ) themes
  );
}
