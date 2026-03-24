{
  flake.modules.homeManager.mpv =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.yt-dlp
        (pkgs.writeShellScriptBin "mpv-mini" ''
          exec ${pkgs.mpv}/bin/mpv --wayland-app-id=mpv-mini --force-window "$@"
        '')
        (pkgs.writeShellScriptBin "umpv-mini" ''
          SOCKET="''${XDG_RUNTIME_DIR:-/tmp}/.umpv-mini"
          if echo '{ "command": ["loadfile", "'"$1"'", "append-play"] }' | ${pkgs.socat}/bin/socat - UNIX-CONNECT:"$SOCKET" 2>/dev/null; then
            exit 0
          fi
          exec ${pkgs.mpv}/bin/mpv --wayland-app-id=mpv-mini --force-window --input-ipc-server="$SOCKET" "$@"
        '')
      ];

      programs.mpv = {
        enable = true;
        bindings = {
          "Shift+LEFT" = "seek -0.1 exact";
          "Shift+RIGHT" = "seek 0.1 exact";
        };
      };

      programs.zsh.shellAliases.mpva = "mpv --no-video";

      xdg.mimeApps.defaultApplications = {
        "audio/*" = "mpv.desktop";
        "video/*" = "mpv.desktop";
      };
    };
}
