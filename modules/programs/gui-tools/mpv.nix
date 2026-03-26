{
  flake.modules.homeManager.mpv =
    { pkgs, config, ... }:
    let
      mpv = config.programs.mpv.finalPackage;
    in
    {
      home.packages = [
        pkgs.yt-dlp
        (pkgs.writeShellScriptBin "mpv-mini" ''
          exec ${mpv}/bin/mpv --wayland-app-id=mpv-mini --force-window "$@"
        '')
        (pkgs.writeShellScriptBin "umpv-mini" ''
          SOCKET="''${XDG_RUNTIME_DIR:-/tmp}/.umpv-mini"
          if echo '{ "command": ["loadfile", "'"$1"'", "append-play"] }' | ${pkgs.socat}/bin/socat - UNIX-CONNECT:"$SOCKET" 2>/dev/null; then
            exit 0
          fi
          exec ${mpv}/bin/mpv --wayland-app-id=mpv-mini --force-window --input-ipc-server="$SOCKET" "$@"
        '')
      ];

      programs.mpv = {
        enable = true;
        scripts = [
          (pkgs.mpvScripts.modernz.overrideAttrs {
            version = "0.3.1";
            src = pkgs.fetchFromGitHub {
              owner = "Samillion";
              repo = "ModernZ";
              tag = "v0.3.1";
              hash = "sha256-xHiKE84qBYa8wnLMhrTnOZPLwdY7ddW7ayIfFz1dIRw=";
            };
          })
        ];
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
