{ inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    { pkgs, lib, ... }:
    {
      imports = [ inputs.noctalia.homeModules.default ];

      home.sessionVariables = {
        QT_QPA_PLATFORMTHEME = lib.mkForce "gtk3";
      };

      home.packages = with pkgs; [
        qt6Packages.qt6ct
        nwg-look
      ];

      programs.noctalia-shell = {
        enable = true;
        systemd.enable = true;

        plugins = {
          sources = [
            {
              enabled = true;
              name = "Official Noctalia Plugins";
              url = "https://github.com/noctalia-dev/noctalia-plugins";
            }
          ];
          states = {
            screenshot = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
          };
          version = 2;
        };

        settings = {
          general = {
            language = "ru";
            enableShadows = false;
            # animationSpeed = 0.5;
            animationDisabled = true;
          };
          bar = {
            outerCorners = false;
            hideOnOverview = true;
            marginVertical = 0;
            marginHorizontal = 0;
          };
          notifications = {
            enableKeyboardLayoutToast = false;
          };
          colorSchemes = {
            predefinedScheme = "Nord";
            useWallpaperColors = false;
            darkMode = true;
          };
          location = {
            name = "Novosibirsk";
          };
          appLauncher = {
            enableClipboardHistory = true;
            autoPasteClipboard = true;
          };
        };
      };
    };
}
