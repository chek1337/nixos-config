{ inputs, ... }:
{
  flake.modules.homeManager.yazi-core =
    { pkgs, ... }:
    let
      # Пин самого бинаря yazi на 26.1.22 — см. комментарий у инпута
      # nixpkgs-yazi в flake.nix. Плагины остаются из основного nixpkgs:
      # старый (пермиссивный) Lua-движок запускает и их тоже.
      pkgsYazi = import inputs.nixpkgs-yazi { inherit (pkgs) system; };
      yaziLauncher = pkgs.writeShellScript "yazi-launcher" ''
        target="''${1:-$HOME}"
        [ -f "$target" ] && target="$(dirname "$target")"
        [ -d "$target" ] || target="$HOME"
        exec ${pkgs.kitty}/bin/kitty --directory "$target" \
          ${pkgs.zsh}/bin/zsh -i -c 'y; exec ${pkgs.zsh}/bin/zsh -i'
      '';
    in
    {
      programs.yazi = {
        enable = true;
        package = pkgsYazi.yazi;
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
            linemode = "mtime";
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
        trash-cli
      ];

      home.file.".duckdbrc".text = ''
        SET lambda_syntax='ENABLE_SINGLE_ARROW';
      '';

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
        exec = "${yaziLauncher} %f";
        terminal = false;
        type = "Application";
        mimeType = [
          "inode/directory"
          "x-scheme-handler/file"
        ];
        categories = [
          "Utility"
          "FileManager"
          "ConsoleOnly"
        ];
      };
    };
}
