{ inputs, ... }:
{
  flake.modules.homeManager.niri-bindings =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # Пин satty на 0.20.1 — см. комментарий у инпута nixpkgs-satty в flake.nix
      # (в 0.21.x crop сломан: Ctrl+C копирует весь экран, а не выделение).
      pkgsSatty = import inputs.nixpkgs-satty { inherit (pkgs) system; };
      satty = "${pkgsSatty.satty}/bin/satty";
      grim = "${pkgs.grim}/bin/grim";
      slurp = "${pkgs.slurp}/bin/slurp";
      wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
      wayfreeze = "${pkgs.wayfreeze}/bin/wayfreeze";
      extraBindLines = lib.concatStringsSep "\n    " (
        lib.mapAttrsToList (key: action: "${key} { ${action}; }") config.services.niri.extraBinds
      );
    in
    {
      config.services.niri._kdl.bindings = ''
        binds {
            Mod+Shift+Slash { show-hotkey-overlay; }

            Ctrl+Shift+1 { switch-layout "0"; }
            Ctrl+Shift+2 { switch-layout "1"; }

            // Noctalia (v5 IPC: `noctalia msg <command> [args]`)
            Mod+Space       { spawn-sh "noctalia msg panel-toggle launcher"; }
            // VPN launchers are global dmenu entries; open the launcher pre-typed "VPN" to filter them.
            Mod+Alt+Space { spawn-sh "noctalia msg panel-open launcher VPN"; }
            Mod+S     { spawn-sh "noctalia msg panel-toggle control-center"; }
            Mod+Comma { spawn-sh "noctalia msg settings-toggle"; }

            Mod+T { spawn "kitty"; }
            Mod+Alt+L { spawn-sh "noctalia msg session lock"; }

            XF86AudioRaiseVolume  { spawn "noctalia" "msg" "volume-up"; }
            XF86AudioLowerVolume  { spawn "noctalia" "msg" "volume-down"; }
            XF86AudioMute         { spawn "noctalia" "msg" "volume-mute"; }
            XF86AudioMicMute      { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
            // v5 has no relative brightness IPC; brightnessctl adjusts and noctalia shows the OSD on the sysfs change.
            XF86MonBrightnessUp   { spawn-sh "${pkgs.brightnessctl}/bin/brightnessctl set 5%+"; }
            XF86MonBrightnessDown { spawn-sh "${pkgs.brightnessctl}/bin/brightnessctl set 5%-"; }

            XF86AudioPlay { spawn-sh "playerctl play-pause"; }
            XF86AudioStop { spawn-sh "playerctl stop"; }
            XF86AudioPrev { spawn-sh "playerctl previous"; }
            XF86AudioNext { spawn-sh "playerctl next"; }

            Mod+O repeat=false { toggle-overview; }
            Mod+Q repeat=false { close-window; }

            Mod+H { focus-column-left; }
            Mod+U { focus-window-down; }
            Mod+I { focus-window-up; }
            Mod+L { focus-column-right; }

            Mod+Ctrl+H { move-column-left; }
            Mod+Ctrl+U { move-window-down; }
            Mod+Ctrl+I { move-window-up; }
            Mod+Ctrl+L { move-column-right; }

            Mod+Home      { focus-column-first; }
            Mod+End       { focus-column-last; }
            Mod+Ctrl+Home { move-column-to-first; }
            Mod+Ctrl+End  { move-column-to-last; }

            Mod+Shift+H { focus-monitor-left; }
            Mod+Shift+U { focus-monitor-down; }
            Mod+Shift+I { focus-monitor-up; }
            Mod+Shift+L { focus-monitor-right; }

            Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
            Mod+Shift+Ctrl+U { move-column-to-monitor-down; }
            Mod+Shift+Ctrl+I { move-column-to-monitor-up; }
            Mod+Shift+Ctrl+L { move-column-to-monitor-right; }

            Mod+J { focus-workspace-down; }
            Mod+K { focus-workspace-up; }
            Mod+Ctrl+J { move-column-to-workspace-down; }
            Mod+Ctrl+K { move-column-to-workspace-up; }
            Mod+Shift+J { move-workspace-down; }
            Mod+Shift+K { move-workspace-up; }

            Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
            Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
            Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
            Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

            Mod+1 { focus-workspace 1; }
            Mod+2 { focus-workspace 2; }
            Mod+3 { focus-workspace 3; }
            Mod+4 { focus-workspace 4; }
            Mod+5 { focus-workspace 5; }
            Mod+6 { focus-workspace 6; }
            Mod+7 { focus-workspace 7; }
            Mod+8 { focus-workspace 8; }
            Mod+9 { focus-workspace 9; }
            Mod+Ctrl+1 { move-column-to-workspace 1; }
            Mod+Ctrl+2 { move-column-to-workspace 2; }
            Mod+Ctrl+3 { move-column-to-workspace 3; }
            Mod+Ctrl+4 { move-column-to-workspace 4; }
            Mod+Ctrl+5 { move-column-to-workspace 5; }
            Mod+Ctrl+6 { move-column-to-workspace 6; }
            Mod+Ctrl+7 { move-column-to-workspace 7; }
            Mod+Ctrl+8 { move-column-to-workspace 8; }
            Mod+Ctrl+9 { move-column-to-workspace 9; }

            Mod+BracketLeft  { consume-or-expel-window-left; }
            Mod+BracketRight { consume-or-expel-window-right; }
            Mod+Period { expel-window-from-column; }

            Mod+R       { switch-preset-column-width; }
            Mod+Shift+R { switch-preset-window-height; }
            Mod+Ctrl+R  { reset-window-height; }
            Mod+F       { maximize-column; }
            Mod+Shift+F { fullscreen-window; }
            Mod+Alt+F   { maximize-window-to-edges; }
            Mod+Ctrl+F  { expand-column-to-available-width; }
            Mod+C       { center-column; }

            Mod+Minus       { set-column-width "-10%"; }
            Mod+Equal       { set-column-width "+10%"; }
            Mod+Ctrl+Minus { set-window-height "-10%"; }
            Mod+Ctrl+Equal { set-window-height "+10%"; }

            Mod+V       { toggle-window-floating; }
            Mod+Alt+V { switch-focus-between-floating-and-tiling; }
            Mod+W       { toggle-column-tabbed-display; }
            // Fork IPC: raise/focus the source app of the most recent notification (its default action).
            Mod+N { spawn "noctalia" "msg" "notification-invoke-latest"; }
            // Still want a "dismiss all toasts" key:
            Mod+Shift+N { spawn "noctalia" "msg" "notification-clear-active"; }

            Print      { spawn-sh "${grim} -t ppm - | ${satty} --filename - --copy-command=${wlCopy} --initial-tool=crop --output-filename=\"~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png\" --actions-on-escape=\"save-to-clipboard,exit\""; }
            Ctrl+Print { spawn-sh "set -e; ${wayfreeze} & PID=$!; sleep 0.1; ${grim} -t ppm -g \"$(${slurp} -o -d)\" - | ${wlCopy}; kill $PID"; }
            Alt+Print  { screenshot-window; }
            Shift+Print { spawn-sh "set -e; ${grim} -t ppm - | ${satty} --filename - --copy-command=${wlCopy} --output-filename=\"~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png\" --actions-on-escape=\"save-to-clipboard,exit\""; }
            Shift+Ctrl+Print { screenshot-screen; }

            Mod+Alt+S { spawn-sh "noctalia msg panel-toggle session"; }

            Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
            Mod+Shift+E     { quit; }
            Ctrl+Alt+Delete { quit; }
            Mod+Alt+P     { power-off-monitors; }

            ${extraBindLines}
        }
      '';
      # Mod+P repeat=false { toggle-window-pinned; }
    };
}
