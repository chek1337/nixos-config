{
  flake.modules.homeManager.firefox =
    { pkgs, config, ... }:
    {
      programs.firefox = {
        enable = true;
        profiles.default = {
          name = "default";
          settings = {
            "browser.theme.content-theme" = 0;
            "browser.theme.toolbar-theme" = 0;
            "browser.display.background_color" = "#${config.lib.stylix.colors.base00-hex}";
          };
        };
      };
    };
}
