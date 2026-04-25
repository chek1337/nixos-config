{
  flake.modules.homeManager.yazi-core =
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
        shellWrapperName = "y";

        settings = {
          mgr = {
            ratio = [
              1
              2
              4
            ];
            sort_by = "natural";
            linemode = "size";
            show_hidden = false;
          };

          preview = {
            max_width = 1920;
            max_height = 1080;
          };
        };

        theme = {
          indicator = {
            padding = {
              open = "█";
              close = "█";
            };
          };
        };
      };

      home.packages = with pkgs; [
        glow
        hexyl
        sqlite
        duckdb
        ouch
        mediainfo
        ffmpeg-headless
        imagemagick
        transmission_4
        wl-clipboard
        xclip
        pandoc
        p7zip
        zip
        udisks2
      ];

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
