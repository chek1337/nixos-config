{
  flake.modules.homeManager.mpv =
    { pkgs-stable, config, ... }:
    let
      mpv = config.programs.mpv.finalPackage;
    in
    {
      home.packages = [
        pkgs-stable.yt-dlp
        (pkgs-stable.writeShellScriptBin "mpv-mini" ''
          exec ${mpv}/bin/mpv --wayland-app-id=mpv-mini --force-window "$@"
        '')
        (pkgs-stable.writeShellScriptBin "umpv-mini" ''
          SOCKET="''${XDG_RUNTIME_DIR:-/tmp}/.umpv-mini"
          if echo '{ "command": ["loadfile", "'"$1"'", "append-play"] }' | ${pkgs-stable.socat}/bin/socat - UNIX-CONNECT:"$SOCKET" 2>/dev/null; then
            exit 0
          fi
          exec ${mpv}/bin/mpv --wayland-app-id=mpv-mini --force-window --input-ipc-server="$SOCKET" "$@"
        '')
      ];

      programs.mpv = {
        enable = true;
        scripts = [
          pkgs-stable.mpvScripts.modernz
          pkgs-stable.mpvScripts.quality-menu
        ];
        config = {
          osc = false;
          osd-bar = false;
          load-select = true;
          load-context-menu = true;
        };
        scriptOpts = {
          modernz = {
            layout = "modern-compact";
          };
        };
        bindings = {
          "UP" = "add volume 5";
          "DOWN" = "add volume -5";
          "Shift+LEFT" = "seek -0.1 exact";
          "Shift+RIGHT" = "seek 0.1 exact";
          "Ctrl+f" = "script-binding quality_menu/video_formats_toggle";
          "MBTN_RIGHT" = "script-binding select/context-menu";
        };
      };

      programs.zsh.shellAliases.mpva = "mpv --no-video";

    };
}
