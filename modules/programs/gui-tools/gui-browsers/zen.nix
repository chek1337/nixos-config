{ inputs, ... }:
{
  flake.modules.homeManager.zen =
    { ... }:
    {
      imports = [ inputs.zen-browser.homeModules.beta ];

      programs.zen-browser = {
        enable = true;
        policies = {
          DisableAppUpdate = true;
        };
        profiles.default = {
          isDefault = true;
          settings = {
            "zen.view.compact" = true;
            "zen.view.compact.hide-tabbar" = true;
            "zen.view.sidebar.expanded" = false;
          };
        };
      };

      stylix.targets.zen-browser.enable = false;

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "zen-beta.desktop";
          "x-scheme-handler/http" = "zen-beta.desktop";
          "x-scheme-handler/https" = "zen-beta.desktop";
        };
      };
    };
}
