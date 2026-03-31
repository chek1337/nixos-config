{
  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    let
      yaziLauncher = pkgs.writeShellScript "yazi-launcher" ''
        exec kitty -e zsh -ic "y; exec zsh"
      '';
    in
    {
      programs.yazi = {
        enable = true;
        enableZshIntegration = false;

        keymap = {
          mgr.prepend_keymap = [
            {
              on = [
                "g"
                "m"
              ];
              run = "cd /run/media/chek";
              desc = "Go to mounted drives";
            }
          ];
        };

        settings = {
          mgr = {
            ratio = [
              1
              2
              4
            ];
          };

          opener = {
            play = [
              {
                run = ''mpv --force-window "$@"'';
                orphan = true;
                for = "unix";
              }
            ];
            image = [
              {
                run = ''imv "$@"'';
                orphan = true;
                for = "unix";
              }
            ];
            extract = [
              {
                run = ''aunpack "$@"'';
                desc = "Extract archive";
                for = "unix";
              }
            ];
            list-archive = [
              {
                run = ''als "$@" | less'';
                desc = "List archive contents";
                for = "unix";
              }
            ];
          };

          open = {
            rules = [
              {
                mime = "audio/*";
                use = "play";
              }
              {
                mime = "video/*";
                use = "play";
              }
              {
                mime = "image/*";
                use = "image";
              }
              {
                mime = "application/zip";
                use = [
                  "extract"
                  "list-archive"
                ];
              }
              {
                mime = "application/*zip*";
                use = [
                  "extract"
                  "list-archive"
                ];
              }
              {
                mime = "application/x-tar";
                use = [
                  "extract"
                  "list-archive"
                ];
              }
              {
                mime = "application/x-bzip*";
                use = [
                  "extract"
                  "list-archive"
                ];
              }
              {
                mime = "application/x-7z-compressed";
                use = [
                  "extract"
                  "list-archive"
                ];
              }
              {
                mime = "application/x-rar";
                use = [
                  "extract"
                  "list-archive"
                ];
              }
              {
                mime = "application/x-xz";
                use = [
                  "extract"
                  "list-archive"
                ];
              }
              {
                mime = "application/gzip";
                use = [
                  "extract"
                  "list-archive"
                ];
              }
              {
                mime = "application/zstd";
                use = [
                  "extract"
                  "list-archive"
                ];
              }
            ];
          };
        };
      };

      programs.zsh.initContent = ''
        function y() {
          local tmp="$(mktemp /tmp/yazi-cwd-XXXXXX)" cwd
          command yazi "$@" --cwd-file="$tmp"
          cwd="$(<"$tmp")"
          [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
          rm -f -- "$tmp"
        }
      '';

      xdg.desktopEntries.yazi = {
        name = "Yazi";
        icon = "yazi";
        comment = "Terminal file manager";
        exec = "${yaziLauncher}";
        terminal = false;
        type = "Application";
        mimeType = [ "inode/directory" ];
        categories = [
          "Utility"
          "FileManager"
          "ConsoleOnly"
        ];
      };
    };
}
