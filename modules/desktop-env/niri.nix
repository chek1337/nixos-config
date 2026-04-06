{ inputs, ... }:
let
  darken = inputs.nix-colorizer.hex.darken;
in
{
  flake.modules.nixos.niri =
    { config, pkgs, ... }:
    let
      username = config.settings.username;
      niri-pinned = pkgs.niri.overrideAttrs (_old: {
        src = inputs.niri-pinned;
        cargoDeps = pkgs.rustPlatform.importCargoLock {
          lockFile = "${inputs.niri-pinned}/Cargo.lock";
          outputHashes = {
            "smithay-0.7.0" = "sha256-D1thFIY9xzmAO903OUpvTMVSXw/o7MZVDfYUG4QJJzs=";
            "smithay-drm-extras-0.1.0" = "sha256-D1thFIY9xzmAO903OUpvTMVSXw/o7MZVDfYUG4QJJzs=";
          };
        };
        postPatch = ''
          patchShebangs resources/niri-session
          substituteInPlace resources/niri.service \
            --replace-fail 'ExecStart=niri' "ExecStart=$out/bin/niri"
        '';
      });
    in
    {
      programs.niri.enable = true;
      programs.niri.package = niri-pinned;
      programs.xwayland.enable = true;
      environment.systemPackages = [ pkgs.xwayland-satellite ];
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
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      cfg = config.services.niri;
      c = config.lib.stylix.colors;
      activeBorder = "#${c.base0D-hex}";
      inactiveBorder = "#${c.base00-hex}";
      backdrop = darken "#${c.base00-hex}" 0.15;
      wgSecret = "/run/secrets/${config.settings.wireguardConfigName}";
      vopono = "${pkgs.vopono}/bin/vopono";
      voponoVpnApps = pkgs.writeShellScript "vopono-vpn-apps" ''
        for i in $(seq 1 30); do
          [ -f ${wgSecret} ] && ${pkgs.systemd}/bin/systemctl is-active --quiet vopono.service && break
          sleep 1
        done
        ${vopono} exec --protocol wireguard --custom ${wgSecret} ${pkgs.qutebrowser}/bin/qutebrowser &
        sleep 3
        ${vopono} exec --protocol wireguard --custom ${wgSecret} ${pkgs.ayugram-desktop}/bin/AyuGram &
        wait
      '';

      # niri-float-sticky = pkgs.buildGoModule {
      #   pname = "niri-float-sticky";
      #   version = "0.0.8";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "probeldev";
      #     repo = "niri-float-sticky";
      #     rev = "v0.0.8";
      #     hash = "sha256-iNd10SZgO+DY+VSqTfDYx19SU2styiG7AC+yLwb9yj8=";
      #   };
      #   vendorHash = "sha256-GqbY3qkPjMxyW9RTsN9hkgM3Bda6A8rb2kR4YQW1nFI=";
      # };

      mkOutputBlock =
        name: out:
        let
          lines =
            [ ]
            ++ lib.optional (out.mode != null) ''mode "${out.mode}"''
            ++ lib.optional (out.scale != null) "    scale ${toString out.scale}"
            ++ lib.optional (out.transform != null) ''transform "${out.transform}"''
            ++ lib.optional (
              out.position != null
            ) "    position x=${toString out.position.x} y=${toString out.position.y}"
            ++ lib.optional (
              out.variableRefreshRate != null
            ) "    variable-refresh-rate ${out.variableRefreshRate}=true";
        in
        ''
          output "${name}" {
          ${lib.concatStringsSep "\n" lines}
          }
        '';

      outputsConfig = lib.concatStringsSep "\n" (lib.mapAttrsToList mkOutputBlock cfg.outputs);

      niriBaseConfig = ''
        input {
            keyboard {
                xkb {
                    layout "us,ru"
                }
                numlock
                track-layout "global"
            }

            mouse {
                accel-speed -0.2
                accel-profile "flat"
                scroll-factor 2.0
            }

            touchpad {
                tap
                natural-scroll
            }
        }

        layout {
            gaps 6

            default-column-width {
                proportion 0.5
            }

            focus-ring {
                off
            }

            border {
                width 2
                active-color "${activeBorder}"
                inactive-color "${inactiveBorder}"
            }
        }

        gestures {
            hot-corners {
                off
            }
        }

        animations {
            window-open {
                duration-ms 75
                curve "ease-out-expo"
            }
            window-close {
                duration-ms 75
                curve "ease-out-expo"
            }
            window-movement {
                duration-ms 75
                curve "ease-out-expo"
            }
            window-resize {
                duration-ms 75
                curve "ease-out-expo"
            }
            workspace-switch {
                duration-ms 100
                curve "ease-out-expo"
            }
            horizontal-view-movement {
                duration-ms 100
                curve "ease-out-expo"
            }
        }

        prefer-no-csd

        screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

        overview {
            backdrop-color "${backdrop}"
        }

        debug {
            honor-xdg-activation-with-invalid-serial
        }

        binds {
            Mod+Shift+Slash { show-hotkey-overlay; }

            Ctrl+Shift+1 { switch-layout "0"; }
            Ctrl+Shift+2 { switch-layout "1"; }

            // Noctalia
            Mod+Space       { spawn-sh "noctalia-shell ipc call launcher toggle"; }
            Mod+Alt+Space { spawn-sh "noctalia-shell ipc call plugin:custom-commands toggle"; }
            Mod+S     { spawn-sh "noctalia-shell ipc call controlCenter toggle"; }
            Mod+Comma { spawn-sh "noctalia-shell ipc call settings toggle"; }

            Mod+T { spawn "kitty"; }
            Mod+Alt+L { spawn-sh "noctalia-shell ipc call lockScreen lock"; }

            XF86AudioRaiseVolume  { spawn "noctalia-shell" "ipc" "call" "volume" "increase"; }
            XF86AudioLowerVolume  { spawn "noctalia-shell" "ipc" "call" "volume" "decrease"; }
            XF86AudioMute         { spawn "noctalia-shell" "ipc" "call" "volume" "muteOutput"; }
            XF86AudioMicMute      { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
            XF86MonBrightnessUp   { spawn "noctalia-shell" "ipc" "call" "brightness" "increase"; }
            XF86MonBrightnessDown { spawn "noctalia-shell" "ipc" "call" "brightness" "decrease"; }

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
            Mod+Ctrl+F  { expand-column-to-available-width; }
            Mod+C       { center-column; }

            Mod+Minus       { set-column-width "-10%"; }
            Mod+Equal       { set-column-width "+10%"; }
            Mod+Ctrl+Minus { set-window-height "-10%"; }
            Mod+Ctrl+Equal { set-window-height "+10%"; }

            Mod+V       { toggle-window-floating; }
            Mod+Shift+V { switch-focus-between-floating-and-tiling; }
            Mod+W       { toggle-column-tabbed-display; }
            Mod+P repeat=false { toggle-window-pinned; }

            Print      { spawn-sh "grim -t ppm - | satty --filename - --copy-command=wl-copy --initial-tool=crop --output-filename=\"~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png\" --actions-on-escape=\"save-to-clipboard,exit\""; }
            Ctrl+Print { spawn-sh "set -e; wayfreeze & PID=$!; sleep 0.1; grim -t ppm -g \"$(slurp -o -d)\" - | wl-copy; kill $PID"; }
            Alt+Print  { screenshot-window; }
            Shift+Print { spawn-sh "set -e; grim -t ppm - | satty --filename - --copy-command=wl-copy --output-filename=\"~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png\" --actions-on-escape=\"save-to-clipboard,exit\""; }
            Shift+Ctrl+Print { screenshot-screen; }

            Mod+Alt+S { spawn-sh "noctalia-shell ipc call sessionMenu toggle"; }

            Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
            Mod+Shift+E     { quit; }
            Ctrl+Alt+Delete { quit; }
            Mod+Alt+P     { power-off-monitors; }
        }


        environment {
            DISPLAY ":0"
        }

        workspace "1"
        workspace "2"
        workspace "3"
        workspace "4"
        workspace "5"
        workspace "6"
        workspace "7"
        workspace "8"
        workspace "9"

        spawn-at-startup "xwayland-satellite"
        spawn-at-startup "noctalia-shell"
        spawn-at-startup "${voponoVpnApps}"
        spawn-at-startup "thunderbird"
        spawn-at-startup "spotify"

        window-rule {
            match app-id=r#"firefox$"# title="^Picture-in-Picture$"
            open-floating true
        }

        window-rule {
            match app-id="qutebrowser" at-startup=true
            open-on-workspace "1"
            open-maximized true
        }

        window-rule {
            match app-id=r"(?i)ayugram"
            open-on-workspace "4"
            open-maximized true
        }

        window-rule {
            match app-id="thunderbird" at-startup=true
            open-on-workspace "5"
            open-maximized true
        }

        window-rule {
            match app-id="spotify" at-startup=true
            open-on-workspace "6"
            open-maximized true
        }


        window-rule {
            match app-id="satty"
            open-floating true
        }

        window-rule {
            match app-id="mpv-mini"
            open-floating true
            open-pinned true
            default-column-width { fixed 320; }
            default-window-height { fixed 180; }
            default-floating-position relative-to="top-right" x=8 y=8
        }
      '';
    in
    {
      options.services.niri.outputs = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              mode = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Output mode, e.g. 1920x1080@144.063";
              };
              scale = lib.mkOption {
                type = lib.types.nullOr lib.types.number;
                default = null;
                description = "Output scale factor";
              };
              transform = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Output transform, e.g. 90, 180, flipped";
              };
              position = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.submodule {
                    options = {
                      x = lib.mkOption { type = lib.types.int; };
                      y = lib.mkOption { type = lib.types.int; };
                    };
                  }
                );
                default = null;
                description = "Output position {x, y}";
              };
              variableRefreshRate = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.enum [
                    "on-demand"
                    "true"
                  ]
                );
                default = null;
                description = "Variable refresh rate mode";
              };
            };
          }
        );
        default = { };
        description = "Niri output (monitor) configurations, keyed by output name";
      };

      config.xdg.configFile."niri/config.kdl".text = outputsConfig + niriBaseConfig;
    };
}
