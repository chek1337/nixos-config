{ inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      noctaliaSchemeMap = {
        "nord" = "Nord";
        "catppuccin-mocha" = "Catppuccin";
        "gruvbox-dark-medium" = "Gruvbox";
      };
      noctaliaScheme = noctaliaSchemeMap.${config.settings.colorScheme} or "Nord";
      iconThemeMap = {
        "nord" = "Nordzy-dark";
        "catppuccin-mocha" = "Papirus-Dark";
        "gruvbox-dark-hard" = "Gruvbox-Plus-Dark";
      };
      iconTheme = iconThemeMap.${config.settings.colorScheme} or "Nordzy-dark";
      isLaptop = config.settings.isLaptop;
      hasBluetooth = config.settings.hasBluetooth;
      wgName = config.settings.wireguardConfigName;
      voponoExec = "${pkgs.vopono}/bin/vopono exec --protocol wireguard --custom /run/secrets/${wgName}";
    in
    {
      imports = [ inputs.noctalia.homeModules.default ];

      home.sessionVariables = {
        QT_QPA_PLATFORMTHEME = lib.mkForce "gtk3";
        QS_ICON_THEME = iconTheme;
      };

      home.packages = with pkgs; [
        qt6Packages.qt6ct
        nwg-look
      ];

      programs.noctalia-shell = {
        enable = true;
        systemd.enable = false;
        plugins = {
          sources = [
            {
              enabled = true;
              name = "Noctalia Plugins";
              url = "https://github.com/noctalia-dev/noctalia-plugins";
            }
          ];
          states = {
            custom-commands = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
          };
          version = 2;
        };
        pluginSettings.custom-commands = {
          commands = [
            {
              name = "qutebrowser (VPN)";
              command = "${voponoExec} ${pkgs.qutebrowser}/bin/qutebrowser";
              icon = "world-www";
            }
            {
              name = "Telegram (VPN)";
              command = "${voponoExec} ${pkgs.telegram-desktop}/bin/Telegram";
              icon = "brand-telegram";
            }
            {
              name = "Yandex Browser (VPN)";
              command = "${voponoExec} yandex-browser-stable";
              icon = "brand-yandex";
            }
          ];
        };
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
            frameRadius = 0;
            showCapsule = true;
            widgetSpacing = 2;
            contentPadding = 0;
            hideOnOverview = true;
            marginVertical = 0;
            marginHorizontal = 0;
            widgets = {
              left = [
                {
                  id = "SystemMonitor";
                }
                {
                  id = "Clock";
                }
                {
                  id = "MediaMini";
                  "maxWidth" = 150;
                  "useFixedWidth" = true;
                  "showArtistFirst" = false;
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
                  displayMode = "forceOpen";
                  showIcon = false;
                }
                {
                  id = "Network";
                }
              ]
              ++ lib.optional hasBluetooth {
                id = "Bluetooth";
              }
              ++ [
                {
                  id = "Volume";
                }
              ]
              ++ lib.optional isLaptop {
                id = "Brightness";
              }
              ++ lib.optional isLaptop {
                id = "Battery";
                displayMode = "alwaysShow";
              }
              ++ [
                {
                  id = "NotificationHistory";
                }
                {
                  id = "ControlCenter";
                }
              ];
            };
          };
          general = {
            radiusRatio = 0;
            iRadiusRatio = 0;
            boxRadiusRatio = 0;
          };
          notifications = {
            enableKeyboardLayoutToast = false;
            density = "compact";
            location = "bottom_right";
          };
          osd = {
            enabledTypes = [
              "Volume"
              "Brightness"
              "LockKey"
            ];
          };
          colorSchemes = {
            predefinedScheme = noctaliaScheme;
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
