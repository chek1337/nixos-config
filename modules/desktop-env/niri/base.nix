{ inputs, ... }:
let
  darken = inputs.nix-colorizer.hex.darken;
in
{
  flake.modules.homeManager.niri-base =
    { config, lib, ... }:
    let
      c = config.lib.stylix.colors;
      activeBorder = "#${c.base0D-hex}";
      inactiveBorder = "#${c.base00-hex}";
      backdrop = darken "#${c.base00-hex}" 0.15;

      defaultSpawns = [
        "xwayland-satellite"
        "awww-daemon"
        "noctalia-shell"
      ];
      allSpawns = defaultSpawns ++ config.services.niri.spawnAtStartup;
      spawnLines = lib.concatMapStringsSep "\n" (s: ''spawn-at-startup "${s}"'') allSpawns;
    in
    {
      config.services.niri._kdl.base = ''
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

        hotkey-overlay {
            skip-at-startup
        }

        debug {
            honor-xdg-activation-with-invalid-serial
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

        ${spawnLines}
      '';
    };
}
