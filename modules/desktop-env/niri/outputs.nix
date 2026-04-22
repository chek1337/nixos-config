{
  flake.modules.homeManager.niri-outputs =
    { config, lib, ... }:
    let
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

      config.services.niri._kdl.outputs = lib.concatStringsSep "\n" (
        lib.mapAttrsToList mkOutputBlock config.services.niri.outputs
      );
    };
}
