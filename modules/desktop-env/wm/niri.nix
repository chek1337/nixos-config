{ inputs, ... }:
{
  flake.modules.nixos.niri =
    { pkgs, config, ... }:
    let
      username = config.settings.username;
    in
    {
      programs.niri.enable = true;
      security.polkit.enable = true;
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "niri-session";
          user = username;
        };
      };
    };

  flake.modules.homeManager.niri =
    { ... }:
    let
      sh = cmd: {
        action.spawn = [
          "sh"
          "-c"
          cmd
        ];
      };
      noctalia = cmd: sh "noctalia-shell ipc call ${cmd}";
    in
    {
      imports = [ inputs.niri.homeModules.config ];

      programs.niri.settings = {
        input = {
          keyboard = {
            xkb.layout = "us,ru";
            numlock = true;
            track-layout = "global";
          };
          mouse = {
            accel-speed = -0.2;
            accel-profile = "flat";
          };
          touchpad = {
            tap = true;
            natural-scroll = true;
          };
        };

        layout = {
          gaps = 8;
          focus-ring = {
            width = 2;
            active.color = "#81A1C1";
            inactive.color = "#4C566A";
          };
          border.enable = false;
        };

        gestures.hot-corners.enable = false;

        prefer-no-csd = true;

        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

        overview.backdrop-color = "#1a1e2a";

        debug = {
          honor-xdg-activation-with-invalid-serial = [ ];
        };

        binds = {
          "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

          "Ctrl+Shift+1".action.switch-layout = "0";
          "Ctrl+Shift+2".action.switch-layout = "1";

          # Noctalia
          "Mod+Space" = noctalia "launcher toggle";
          "Mod+S" = noctalia "controlCenter toggle";
          "Mod+Comma" = noctalia "settings toggle";

          "Mod+T".action.spawn = "kitty";
          "Mod+Alt+L" = noctalia "lockScreen lock";

          "XF86AudioRaiseVolume".action.spawn = [
            "noctalia-shell"
            "ipc"
            "call"
            "volume"
            "increase"
          ];
          "XF86AudioLowerVolume".action.spawn = [
            "noctalia-shell"
            "ipc"
            "call"
            "volume"
            "decrease"
          ];
          "XF86AudioMute".action.spawn = [
            "noctalia-shell"
            "ipc"
            "call"
            "volume"
            "muteOutput"
          ];
          "XF86AudioMicMute" = sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          "XF86MonBrightnessUp".action.spawn = [
            "noctalia-shell"
            "ipc"
            "call"
            "brightness"
            "increase"
          ];
          "XF86MonBrightnessDown".action.spawn = [
            "noctalia-shell"
            "ipc"
            "call"
            "brightness"
            "decrease"
          ];

          "XF86AudioPlay" = sh "playerctl play-pause";
          "XF86AudioStop" = sh "playerctl stop";
          "XF86AudioPrev" = sh "playerctl previous";
          "XF86AudioNext" = sh "playerctl next";

          "Mod+O" = {
            action.toggle-overview = [ ];
            repeat = false;
          };
          "Mod+Q" = {
            action.close-window = [ ];
            repeat = false;
          };

          "Mod+H".action.focus-column-left = [ ];
          "Mod+J".action.focus-window-down = [ ];
          "Mod+K".action.focus-window-up = [ ];
          "Mod+L".action.focus-column-right = [ ];

          "Mod+Ctrl+H".action.move-column-left = [ ];
          "Mod+Ctrl+J".action.move-window-down = [ ];
          "Mod+Ctrl+K".action.move-window-up = [ ];
          "Mod+Ctrl+L".action.move-column-right = [ ];

          "Mod+Home".action.focus-column-first = [ ];
          "Mod+End".action.focus-column-last = [ ];
          "Mod+Ctrl+Home".action.move-column-to-first = [ ];
          "Mod+Ctrl+End".action.move-column-to-last = [ ];

          "Mod+Shift+H".action.focus-monitor-left = [ ];
          "Mod+Shift+J".action.focus-monitor-down = [ ];
          "Mod+Shift+K".action.focus-monitor-up = [ ];
          "Mod+Shift+L".action.focus-monitor-right = [ ];

          "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
          "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
          "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
          "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

          "Mod+U".action.focus-workspace-down = [ ];
          "Mod+I".action.focus-workspace-up = [ ];
          "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
          "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];
          "Mod+Shift+U".action.move-workspace-down = [ ];
          "Mod+Shift+I".action.move-workspace-up = [ ];

          "Mod+WheelScrollDown" = {
            action.focus-workspace-down = [ ];
            cooldown-ms = 150;
          };
          "Mod+WheelScrollUp" = {
            action.focus-workspace-up = [ ];
            cooldown-ms = 150;
          };
          "Mod+Ctrl+WheelScrollDown" = {
            action.move-column-to-workspace-down = [ ];
            cooldown-ms = 150;
          };
          "Mod+Ctrl+WheelScrollUp" = {
            action.move-column-to-workspace-up = [ ];
            cooldown-ms = 150;
          };

          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;
          "Mod+Ctrl+1".action.move-column-to-workspace = 1;
          "Mod+Ctrl+2".action.move-column-to-workspace = 2;
          "Mod+Ctrl+3".action.move-column-to-workspace = 3;
          "Mod+Ctrl+4".action.move-column-to-workspace = 4;
          "Mod+Ctrl+5".action.move-column-to-workspace = 5;
          "Mod+Ctrl+6".action.move-column-to-workspace = 6;
          "Mod+Ctrl+7".action.move-column-to-workspace = 7;
          "Mod+Ctrl+8".action.move-column-to-workspace = 8;
          "Mod+Ctrl+9".action.move-column-to-workspace = 9;

          "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
          "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
          "Mod+Period".action.expel-window-from-column = [ ];

          "Mod+R".action.switch-preset-column-width = [ ];
          "Mod+Shift+R".action.switch-preset-window-height = [ ];
          "Mod+Ctrl+R".action.reset-window-height = [ ];
          "Mod+F".action.maximize-column = [ ];
          "Mod+Shift+F".action.fullscreen-window = [ ];
          "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];
          "Mod+C".action.center-column = [ ];

          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Ctrl+Minus".action.set-window-height = "-10%";
          "Mod+Ctrl+Equal".action.set-window-height = "+10%";

          "Mod+V".action.toggle-window-floating = [ ];
          "Mod+Ctrl+V".action.switch-focus-between-floating-and-tiling = [ ];
          "Mod+W".action.toggle-column-tabbed-display = [ ];

          "Print" = sh ''grim -g "$(slurp)" - | wl-copy'';
          "Ctrl+Print" =
            sh ''grim -g "$(slurp)" - | satty --filename - --early-exit --copy-command 'wl-copy' '';
          "Alt+Print".action.screenshot-window = [ ];
          "Shift+Print".action.screenshot-screen = [ ];
          "Shift+Ctrl+Print" = sh "grim - | satty --filename - --early-exit --copy-command 'wl-copy'";

          "Mod+Alt+S" = noctalia "sessionMenu toggle";

          "Mod+Escape" = {
            action.toggle-keyboard-shortcuts-inhibit = [ ];
            allow-inhibiting = false;
          };
          "Mod+Shift+E".action.quit = [ ];
          "Ctrl+Alt+Delete".action.quit = [ ];
          "Mod+Alt+P".action.power-off-monitors = [ ];
        };

        workspaces = {
          "01" = { };
          "02" = { };
          "03" = { };
          "04" = { };
          "05" = { };
          "06" = { };
          "07" = { };
          "08" = { };
          "09" = { };
        };

        spawn-at-startup = [
          { argv = [ "kitty" ]; }
          { argv = [ "spotify" ]; }
        ];

        window-rules = [
          {
            matches = [
              {
                app-id = "qutebrowser";
                at-startup = true;
              }
            ];
            open-on-workspace = "01";
            open-maximized = true;
          }
          {
            matches = [
              {
                app-id = "kitty";
                at-startup = true;
              }
            ];
            open-on-workspace = "02";
          }
          {
            matches = [
              {
                app-id = "org.telegram.desktop";
                at-startup = true;
              }
            ];
            open-on-workspace = "03";
            open-maximized = true;
          }
          {
            matches = [
              {
                app-id = "spotify";
                at-startup = true;
              }
            ];
            open-on-workspace = "04";
            open-maximized = true;
          }
          {
            matches = [
              {
                app-id = "firefox$";
                title = "^Picture-in-Picture$";
              }
            ];
            open-floating = true;
          }
          {
            geometry-corner-radius =
              let
                r = 4.0;
              in
              {
                top-left = r;
                top-right = r;
                bottom-left = r;
                bottom-right = r;
              };
            clip-to-geometry = true;
          }
          {
            matches = [ { app-id = "satty"; } ];
            open-floating = true;
          }
        ];
      };
    };
}
