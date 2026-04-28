{ config, inputs, ... }:
let
  hmMods = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.niri =
    { pkgs, ... }:
    # let
    #   niri-pinned = pkgs.niri.overrideAttrs (_old: {
    #     src = inputs.niri-pinned;
    #     cargoDeps = pkgs.rustPlatform.importCargoLock {
    #       lockFile = "${inputs.niri-pinned}/Cargo.lock";
    #       outputHashes = {
    #         "smithay-0.7.0" = "sha256-D1thFIY9xzmAO903OUpvTMVSXw/o7MZVDfYUG4QJJzs=";
    #         "smithay-drm-extras-0.1.0" = "sha256-D1thFIY9xzmAO903OUpvTMVSXw/o7MZVDfYUG4QJJzs=";
    #       };
    #     };
    #     postPatch = ''
    #       patchShebangs resources/niri-session
    #       substituteInPlace resources/niri.service \
    #         --replace-fail 'ExecStart=niri' "ExecStart=$out/bin/niri"
    #     '';
    #   });
    # in
    {
      programs.niri.enable = true;
      environment.systemPackages = [ pkgs.xwayland-satellite ];
    };

  flake.modules.homeManager.niri =
    { config, lib, ... }:
    {
      imports = with hmMods; [
        niri-outputs
        niri-base
        niri-bindings
        niri-window-rules
      ];

      options.services.niri = {
        spawnAtStartup = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = ''
            Programs to spawn at niri startup. Each entry becomes a
            `spawn-at-startup "<value>"` line. Use this from other modules to
            integrate with niri without editing its config directly.
          '';
        };

        windowRules = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = ''
            Extra raw-KDL `window-rule { ... }` blocks, appended verbatim.
          '';
        };

        extraBinds = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          example = {
            "Mod+X repeat=false" = ''spawn "firefox"'';
          };
          description = ''
            Additional keybinds merged into the binds block. Attribute name is
            the key spec plus any flags (e.g. `Mod+X repeat=false`); value is
            the action body (trailing `;` is added automatically).
          '';
        };

        _kdl = lib.mkOption {
          type = lib.types.submodule {
            options = {
              outputs = lib.mkOption {
                type = lib.types.str;
                default = "";
              };
              base = lib.mkOption {
                type = lib.types.str;
                default = "";
              };
              bindings = lib.mkOption {
                type = lib.types.str;
                default = "";
              };
              windowRules = lib.mkOption {
                type = lib.types.str;
                default = "";
              };
            };
          };
          default = { };
          internal = true;
          description = "KDL fragments composed into the final niri config.";
        };
      };

      config.xdg.configFile."niri/config.kdl".text = lib.concatStringsSep "\n\n" (
        lib.filter (s: s != "") [
          config.services.niri._kdl.outputs
          config.services.niri._kdl.base
          config.services.niri._kdl.bindings
          config.services.niri._kdl.windowRules
        ]
      );
    };
}
