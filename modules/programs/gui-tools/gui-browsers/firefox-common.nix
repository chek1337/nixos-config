{
  flake.modules.homeManager.firefox-common =
    {
      config,
      lib,
      ...
    }:
    {
      options.firefoxCommon = {
        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          readOnly = true;
        };
        policies = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          readOnly = true;
        };
        extensions = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          readOnly = true;
        };
      };

      config = {
        home.shellAliases.search-firefox-addon = "nix run github:osipog/nix-firefox-addons#search-addon";

        firefoxCommon.settings = {
          "browser.theme.content-theme" = 0;
          "browser.theme.toolbar-theme" = 0;
          "browser.display.background_color" = "#${config.lib.stylix.colors.base00-hex}";
          "intl.locale.requested" = "ru,en-US";
          "intl.accept_languages" = "ru-RU, ru, en-US, en";
          "layout.css.prefers-color-scheme.content-override" = 0;
          "browser.startup.page" = 3;
          "webgl.disabled" = false;
          "privacy.resistFingerprinting" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "network.cookie.lifetimePolicy" = 0;
        };

        firefoxCommon.policies = {
          Bookmarks = map (b: {
            Title = b.name;
            URL = b.url;
          }) config.browserBookmarks;
          AppAutoUpdate = false;
          BackgroundAppUpdate = false;
          DisableAccounts = true;
          DisableFirefoxAccounts = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisplayBookmarksToolbar = "never";
          DontCheckDefaultBrowser = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
            EmailTracking = true;
          };
          ExtensionUpdate = false;
          FirefoxHome = {
            TopSites = false;
            SponsoredTopSites = false;
            Highlights = false;
            Snippets = false;
            Pocket = false;
            SponsoredPocket = false;
            Locked = true;
          };
          FirefoxSuggest = {
            WebSuggestions = false;
            SponsoredSuggestions = false;
            ImproveSuggest = false;
            Locked = true;
          };
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          Permissions = {
            Location = {
              BlockNewRequests = true;
              Locked = true;
            };
            Notifications = {
              BlockNewRequests = true;
              Locked = true;
            };
            Autoplay = {
              Default = "block-audio-video";
              Locked = true;
            };
          };
          PostQuantumKeyAgreementEnabled = true;
          Preferences = {
            "extensions.autoDisableScopes" = 0;
          };
          SearchSuggestEnabled = false;
          ShowHomeButton = false;
          TranslateEnabled = false;
          UserMessaging = {
            ExtensionRecommendations = false;
            FeatureRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = false;
            MoreFromMozilla = false;
            FirefoxLabs = false;
            Locked = true;
          };
        };

        firefoxCommon.extensions = config.browserExtensions.firefoxPackages;

      };
    };
}
