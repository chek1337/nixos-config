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
        settings = {
          general = {
            language = "ru";
            enableShadows = false;
            # animationSpeed = 0.5;
            animationDisabled = true;
          };
          dock = {
            enabled = false;
          };
          bar = {
            outerCorners = false;
            hideOnOverview = true;
            marginVertical = 0;
            marginHorizontal = 0;
            widgets = {
              left = [
                {
                  id = "Clock";
                }
                {
                  id = "SystemMonitor";
                }
                {
                  id = "ActiveWindow";
                }
                {
                  id = "MediaMini";
                }
              ];
              center = [
                {
                  id = "Workspace";
                }
              ];
              right = [
                {
                  id = "Tray";
                }
                {
                  id = "KeyboardLayout";
                  settings = {
                    displayMode = "forceOpen";
                    showIcon = false;
                  };
                }
                {
                  id = "NotificationHistory";
                }
                {
                  id = "Battery";
                }
                {
                  id = "Volume";
                }
                {
                  id = "Brightness";
                }
                {
                  id = "ControlCenter";
                }
              ];
            };
          };
          notifications = {
            enableKeyboardLayoutToast = false;
            density = "compact";
          };
          colorSchemes = {
            predefinedScheme = "Nord";
            useWallpaperColors = false;
            darkMode = true;
          };
          templates = {
            enableUserTheming = true;
            activeTemplates = [ "telegram" ];
          };
          location = {
            name = "Novosibirsk";
          };
          appLauncher = {
            enableClipboardHistory = true;
            autoPasteClipboard = true;
            screenshotAnnotationTool = "satty";
          };
        };
      };
    };
}
