{ ... }:
{
  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    let
      aminurSrc = pkgs.fetchFromGitHub {
        owner = "AminurAlam";
        repo = "yazi-plugins";
        rev = "8ed61d7c0cc1902963f59020d3c87f505adc8273";
        hash = "sha256-KEz/o1Sk5hydzMSje/2u80hnuBnUyDxnMhyT00T4zQI=";
      };
      anirudhSrc = pkgs.fetchFromGitHub {
        owner = "AnirudhG07";
        repo = "plugins-yazi";
        rev = "71545f4ee1a0896c555b3118dc3d2b0a1b92fad9";
        hash = "sha256-JsQJg/SfXLQ/JIpl2YsfzdGpS1ZeWIACJwWTpHaVH3w=";
      };
      subPlugin =
        src: name:
        pkgs.runCommand "${name}.yazi" { } ''
          cp -r ${src}/${name}.yazi $out
        '';
    in
    {
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";

        plugins = {
          piper = pkgs.yaziPlugins.piper;
          relative-motions = pkgs.yaziPlugins.relative-motions;
          duckdb = pkgs.yaziPlugins.duckdb;
          ouch = pkgs.yaziPlugins.ouch;

          eza-preview = pkgs.fetchFromGitHub {
            owner = "ahkohd";
            repo = "eza-preview.yazi";
            rev = "7a2d60f4a88a1a7735efde93e03bdb8c7166d00c";
            hash = "sha256-0CKwpNeTt221RXM4SpdUxu/TnghbX2hlIscMGxGaO34=";
          };

          mediainfo = pkgs.fetchFromGitHub {
            owner = "boydaihungst";
            repo = "mediainfo.yazi";
            rev = "49f5ab722d617a64b3bea87944e3e4e17ba3a46b";
            hash = "sha256-PcGrFG06XiJYgBWq+c7fYsx1kjkCvIYRaBiWaJT+xkw=";
          };

          pickle = pkgs.fetchFromGitHub {
            owner = "dimi1357";
            repo = "pickle.yazi";
            rev = "7f5b75c971c7f7db07320c8aa37b59f25936d496";
            hash = "sha256-g1BoqtI97641Fh1pTqlyasKG6+gdAWeeHrC/ouyFw/A=";
          };

          font-sample = subPlugin aminurSrc "font-sample";
          preview-git = subPlugin aminurSrc "preview-git";
          copy-file-contents = subPlugin anirudhSrc "copy-file-contents";

          chmod = pkgs.yaziPlugins.chmod;
          compress = pkgs.yaziPlugins.compress;
          mount = pkgs.yaziPlugins.mount;
          recycle-bin = pkgs.yaziPlugins.recycle-bin;
          restore = pkgs.yaziPlugins.restore;

          fast-enter = pkgs.fetchFromGitHub {
            owner = "ourongxing";
            repo = "fast-enter.yazi";
            rev = "9fe77d8292c6bc63538acdc97cb91b81542e85a4";
            hash = "sha256-E0r0XsyECKMJ8w+9OVJKDggSXhAqlwD3u9ZSEXHc6J0=";
          };

          ucp = pkgs.fetchFromGitHub {
            owner = "simla33";
            repo = "ucp.yazi";
            rev = "b74651dae2fdb02e5706ec8227b2dd33e00f48a9";
            hash = "sha256-XdDUlu43cZUnYDoKhnXlx15jYqnh6ubrbbrzJ0B45vc=";
          };

          pandoc = pkgs.fetchFromGitHub {
            owner = "lmnek";
            repo = "pandoc.yazi";
            rev = "fd2798b79c12d0ee1fc0b8695c2633705529f07b";
            hash = "sha256-3ID/CvogyYA92qpc+lCN1fNovFn4X+pt4iEdKzN2Ncw=";
          };

          convert = pkgs.fetchFromGitHub {
            owner = "atareao";
            repo = "convert.yazi";
            rev = "ce060d9d17e4466d7956213d68a7a74d24ecfdc5";
            hash = "sha256-kCXjwtcOQZbE+S9PgJrBmlzBcdprSGtfiS2Flxe2olw=";
          };

          television = pkgs.fetchFromGitHub {
            owner = "moxuze";
            repo = "television.yazi";
            rev = "8d9ce62c447cc8c9cf7f68f857a6b744820bca4b";
            hash = "sha256-TRz1tpOhVOG55AvkLNxSmwWaElX84+DxvoVdfOwzsTI=";
          };
          tv-sel = pkgs.writeTextDir "main.lua" ''
            local M = {}

            local get_state = ya.sync(function()
              local sel = {}
              for _, url in pairs(cx.active.selected) do
                sel[#sel + 1] = tostring(url)
              end
              return { selected = sel, cwd = tostring(cx.active.current.cwd) }
            end)

            function M:entry()
              local state = get_state()

              if #state.selected == 0 then
                ya.notify({
                  title = "tv-sel",
                  content = "No files selected",
                  level = "warn",
                  timeout = 3,
                })
                return
              end

              local tmp_list = "/tmp/yazi-sel-grep-files-" .. (os.getenv("USER") or "user")
              local lf = io.open(tmp_list, "w")
              for _, f in ipairs(state.selected) do
                lf:write(f .. "\n")
              end
              lf:close()

              local cfg_dir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/television/cable"
              os.execute("mkdir -p " .. cfg_dir)
              local cf = io.open(cfg_dir .. "/yazi-sel-grep.toml", "w")
              cf:write(string.format([[
            [metadata]
            name = "yazi-sel-grep"
            description = "Grep in yazi-selected files"
            requirements = ["rg", "bat"]

            [source]
            command = "xargs -d '\\n' -a %s rg . --with-filename --no-heading --line-number --colors 'match:fg:white' --colors 'path:fg:blue' --color=always"
            ansi = true
            display = "{strip_ansi|split:\\::2..}"
            output = "{strip_ansi|split:\\::..2}"

            [preview]
            command = "bat -n --color=always --highlight-line '{strip_ansi|split:\\::1}' '{strip_ansi|split:\\::0}'"
            env = { BAT_THEME = "ansi" }
            offset = '{strip_ansi|split:\\::1}'

            [ui.preview_panel]
            header = "{strip_ansi|split:\\::..2}"
            ]], tmp_list))
              cf:close()

              local tmp_out = os.tmpname()
              local permit = ui.hide()
              local child = Command("sh")
                :arg("-c")
                :arg(string.format(
                  [[tv --no-remote --keybindings='enter="confirm_selection"' yazi-sel-grep > %s]],
                  ya.quote(tmp_out)
                ))
                :cwd(state.cwd)
                :stdin(Command.INHERIT)
                :stdout(Command.INHERIT)
                :stderr(Command.INHERIT)
                :spawn()
              if child then child:wait() end
              permit:drop()

              local of = io.open(tmp_out, "r")
              if not of then return end
              local line = of:read("*all"):gsub("[\r\n]+$", "")
              of:close()
              os.remove(tmp_out)
              if line == "" then return end

              local file, row = line:match("^(.+):(%d+)$")
              if not file then return end

              permit = ui.hide()
              local nv = Command("sh")
                :arg("-c")
                :arg(string.format("nvim %s +%s", ya.quote(file), row))
                :cwd(state.cwd)
                :stdin(Command.INHERIT)
                :stdout(Command.INHERIT)
                :stderr(Command.INHERIT)
                :spawn()
              if nv then nv:wait() end
              permit:drop()

              ya.emit("reveal", { Url(file), raw = true })
            end

            return M
          '';
        };

        initLua = ''
          require("relative-motions"):setup({ show_numbers = "relative", show_motion = true })
          require("eza-preview"):setup({})
        '';

        keymap.mgr.prepend_keymap = [
          {
            on = "1";
            run = "plugin relative-motions --args=1";
            desc = "Relative motion 1";
          }
          {
            on = "2";
            run = "plugin relative-motions --args=2";
            desc = "Relative motion 2";
          }
          {
            on = "3";
            run = "plugin relative-motions --args=3";
            desc = "Relative motion 3";
          }
          {
            on = "4";
            run = "plugin relative-motions --args=4";
            desc = "Relative motion 4";
          }
          {
            on = "5";
            run = "plugin relative-motions --args=5";
            desc = "Relative motion 5";
          }
          {
            on = "6";
            run = "plugin relative-motions --args=6";
            desc = "Relative motion 6";
          }
          {
            on = "7";
            run = "plugin relative-motions --args=7";
            desc = "Relative motion 7";
          }
          {
            on = "8";
            run = "plugin relative-motions --args=8";
            desc = "Relative motion 8";
          }
          {
            on = "9";
            run = "plugin relative-motions --args=9";
            desc = "Relative motion 9";
          }
          {
            on = [
              "<Space>"
              "f"
              "f"
            ];
            run = "plugin television -- files";
            desc = "Find files (television)";
          }
          {
            on = [
              "<Space>"
              "s"
              "g"
            ];
            run = "plugin television -- text --text";
            desc = "Grep text (television)";
          }
          {
            on = [
              "<Space>"
              "s"
              "s"
            ];
            run = "plugin tv-sel";
            desc = "Grep in selected files (television)";
          }
          {
            on = [
              "e"
              "t"
            ];
            run = "plugin eza-preview";
            desc = "Toggle tree/list dir preview";
          }
          {
            on = [
              "e"
              "+"
            ];
            run = "plugin eza-preview inc-level";
            desc = "Increment tree level";
          }
          {
            on = [
              "e"
              "-"
            ];
            run = "plugin eza-preview dec-level";
            desc = "Decrement tree level";
          }
          {
            on = [
              "e"
              "$"
            ];
            run = "plugin eza-preview toggle-follow-symlinks";
            desc = "Toggle tree follow symlinks";
          }
          {
            on = [
              "e"
              "*"
            ];
            run = "plugin eza-preview toggle-hidden";
            desc = "Toggle hidden files";
          }
          {
            on = [
              "e"
              "g"
              "i"
            ];
            run = "plugin eza-preview toggle-git-ignore";
            desc = "Toggle .gitignore files";
          }
          {
            on = [
              "e"
              "g"
              "s"
            ];
            run = "plugin eza-preview toggle-git-status";
            desc = "Toggle showing git status";
          }
          # I dont wanna to enter to files randomly
          # {
          #   on = "l";
          #   run = "plugin fast-enter";
          #   desc = "Enter subfolder / open file (fast-enter)";
          # }
          {
            on = "y";
            run = "plugin ucp copy notify";
            desc = "Copy to system clipboard (ucp)";
          }
          {
            on = "p";
            run = "plugin ucp paste notify";
            desc = "Paste from system clipboard (ucp)";
          }
          {
            on = "<A-y>";
            run = "plugin copy-file-contents";
            desc = "Copy file contents to clipboard";
          }
          {
            on = "u";
            run = "plugin restore";
            desc = "Restore last deleted (restore)";
          }
          {
            on = [
              "<Space>"
              "r"
              "b"
            ];
            run = "plugin recycle-bin";
            desc = "Open recycle bin";
          }
          {
            on = "M";
            run = "plugin mount";
            desc = "Mount manager";
          }
          {
            on = [
              "c"
              "m"
            ];
            run = "plugin chmod";
            desc = "Chmod selected files";
          }
          {
            on = [
              "c"
              "a"
            ];
            run = "plugin compress";
            desc = "Compress selected files (archive)";
          }
          {
            on = [
              "c"
              "p"
            ];
            run = "plugin pandoc";
            desc = "Pandoc: convert document";
          }
          {
            on = [
              "i"
              "p"
            ];
            run = "plugin convert -- --extension=png";
            desc = "Convert image to PNG";
          }
          {
            on = [
              "i"
              "j"
            ];
            run = "plugin convert -- --extension=jpg";
            desc = "Convert image to JPG";
          }
          {
            on = [
              "i"
              "w"
            ];
            run = "plugin convert -- --extension=webp";
            desc = "Convert image to WebP";
          }
        ];

        settings = {
          mgr = {
            ratio = [
              1
              2
              4
            ];
            sort_by = "natural";
            linemode = "size";
            show_hidden = true;
          };

          preview = {
            max_width = 1920;
            max_height = 1080;
          };

          plugin = {
            prepend_previewers = [
              # Plugin-based previewers
              {
                url = "*/";
                run = "eza-preview";
              }
              {
                url = "*.csv";
                run = "duckdb";
              }
              {
                url = "*.tsv";
                run = "duckdb";
              }
              {
                url = "*.json";
                run = "duckdb";
              }
              {
                url = "*.parquet";
                run = "duckdb";
              }
              {
                url = "*.xlsx";
                run = "duckdb";
              }
              {
                url = "*.duckdb";
                run = "duckdb";
              }
              {
                mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
                run = "ouch";
              }
              {
                mime = "video/*";
                run = "mediainfo";
              }
              {
                mime = "audio/*";
                run = "mediainfo";
              }
              {
                mime = "image/*";
                run = "mediainfo";
              }
              {
                mime = "font/*";
                run = "font-sample";
              }
              {
                mime = "application/ms-opentype";
                run = "font-sample";
              }
              {
                url = "*.{otf,ttf,woff,woff2}";
                run = "font-sample";
              }
              {
                url = "*.pkl";
                run = "pickle";
              }
              {
                url = "*.pickle";
                run = "pickle";
              }
              {
                url = "**/.git/";
                run = "preview-git";
              }
              # Piper-based previewers
              {
                url = "*.md";
                run = ''piper -- env CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
              }
              {
                mime = "application/sqlite3";
                run = ''piper -- sqlite3 "$1" ".schema --indent"'';
              }
              {
                mime = "application/bittorrent";
                run = ''piper -- transmission-show "$1"'';
              }
            ];
            prepend_preloaders = [
              {
                mime = "video/*";
                run = "mediainfo";
              }
              {
                mime = "audio/*";
                run = "mediainfo";
              }
              {
                mime = "image/*";
                run = "mediainfo";
              }
              {
                mime = "font/*";
                run = "font-sample";
              }
              {
                mime = "application/ms-opentype";
                run = "font-sample";
              }
              {
                url = "*.{otf,ttf,woff,woff2}";
                run = "font-sample";
              }
            ];
            append_previewers = [
              {
                url = "*";
                run = ''piper -- hexyl --border=none --terminal-width=$w "$1"'';
              }
            ];
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
    };
}
