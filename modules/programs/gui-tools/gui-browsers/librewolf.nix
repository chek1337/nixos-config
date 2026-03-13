{
  flake.modules.homeManager.librewolf =
    { pkgs, ... }:
    {
      programs.librewolf = {
        enable = true;
        policies = {
          ExtensionSettings = {
            "{f4c9e1d6-6630-4600-ad50-d223eab7f3e7}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/nordby/latest.xpi";
              installation_mode = "force_installed";
            };
          };
        };
        profiles.default = {
          name = "default";
          settings = {
            "intl.locale.requested" = "ru,en-US";
            "intl.accept_languages" = "ru-RU, ru, en-US, en";
            "layout.css.prefers-color-scheme.content-override" = 0;
            "browser.theme.content-theme" = 0; # Dark theme
            "browser.startup.page" = 3;
            "webgl.disabled" = false;
            "privacy.resistFingerprinting" = false;
            "privacy.clearOnShutdown.history" = false;
            "privacy.clearOnShutdown.cookies" = false;
            "network.cookie.lifetimePolicy" = 0;
          };
        };
      };
    };
}
