{
  flake.modules.homeManager.niri-blur =
    { config, lib, ... }:
    let
      cfg = config.services.niri.blur;
      xrayKdl = if cfg.xray then "true" else "false";
    in
    {
      options.services.niri.blur = {
        enable = lib.mkEnableOption "background blur for niri windows and noctalia layers (requires niri >= 26.04)";

        passes = lib.mkOption {
          type = lib.types.int;
          default = 3;
          description = "Number of blur passes. Higher = stronger blur.";
        };

        offset = lib.mkOption {
          type = lib.types.float;
          default = 3.0;
          description = "Sample distance per blur pass.";
        };

        noise = lib.mkOption {
          type = lib.types.float;
          default = 0.02;
          description = "Grain overlay applied on top of the blur.";
        };

        saturation = lib.mkOption {
          type = lib.types.float;
          default = 1.5;
          description = "Color saturation boost in the blurred area.";
        };

        xray = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Whether to use xray blur (sees through to wallpaper) or full blur
            (sees everything beneath the window). Non-xray gives a richer look
            but is more expensive; xray is the niri default and is cheaper.
          '';
        };

        applyToNoctalia = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Whether to add a layer-rule matching noctalia surfaces
            (bar, panels, dock) so the blur applies there too.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        stylix.opacity.terminal = lib.mkDefault 0.7;

        services.niri._kdl.extra = ''
          blur {
              passes ${toString cfg.passes}
              offset ${toString cfg.offset}
              noise ${toString cfg.noise}
              saturation ${toString cfg.saturation}
          }

          window-rule {
              background-effect {
                  blur true
                  xray ${xrayKdl}
              }
          }
        ''
        + lib.optionalString cfg.applyToNoctalia ''

          layer-rule {
              match namespace="^noctalia-(bar-.*|panel|attached-panel|dock)$"
              background-effect {
                  xray ${xrayKdl}
              }
          }
        '';
      };
    };
}
