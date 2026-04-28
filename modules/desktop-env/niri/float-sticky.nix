{ inputs, ... }:
{
  flake.modules.homeManager.niri-float-sticky =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.niri-float-sticky;
      package = inputs.niri-float-sticky.packages.${pkgs.system}.default;
      bin = "${package}/bin/niri-float-sticky";

      mkPatternArgs = flag: patterns: lib.concatStringsSep " " (map (p: ''${flag} "${p}"'') patterns);

      hasPatterns = cfg.appIds != [ ] || cfg.titles != [ ];
      args =
        if hasPatterns then
          "${mkPatternArgs "-app-id" cfg.appIds} ${mkPatternArgs "-title" cfg.titles}"
        else
          "-disable-auto-stick";

      stickyWrapper = pkgs.writeShellScript "niri-float-sticky-launch" ''
        exec ${bin} ${args}
      '';
    in
    {
      options.services.niri-float-sticky = {
        appIds = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = ''
            Regex patterns matched against window app-id. Floating windows
            whose app-id matches are auto-pinned across all workspaces. When
            both `appIds` and `titles` are empty, auto-stick is disabled
            entirely and only the manual toggle bind affects stickiness.
          '';
        };

        titles = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Regex patterns matched against window title for auto-pin.";
        };

        toggleBind = lib.mkOption {
          type = lib.types.str;
          default = "Mod+P repeat=false";
          description = ''
            Niri keybind spec (key plus flags) for toggling sticky on the
            focused floating window. Empty string disables the bind.
          '';
        };
      };

      config = {
        home.packages = [ package ];

        services.niri = {
          spawnAtStartup = [ "${stickyWrapper}" ];

          extraBinds = lib.optionalAttrs (cfg.toggleBind != "") {
            ${cfg.toggleBind} = ''spawn "${bin}" "-ipc" "toggle_sticky"'';
          };
        };
      };
    };
}
