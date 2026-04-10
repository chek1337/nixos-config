{ ... }:
{
  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    let
      yaziLauncher = pkgs.writeShellScript "yazi-launcher" ''
        exec kitty -e zsh -ic "y; exec zsh"
      '';
      fzfBatPreview = pkgs.writeShellScriptBin "fzf-bat-preview" ''
        # https://github.com/sharkdp/bat/issues/388#issuecomment-652292548
        set -eEuCo pipefail
        declare -r file=$1
        declare -i -r line=$2
        declare -i -r lines=$LINES
        declare -i center=$(( (lines - 3) / 2 ))
        if [ $line -lt $center ]; then
            center=$line
        fi
        declare -i -r start=$(( line - center ))
        declare -i -r end=$(( lines + start ))
        exec bat --color always --highlight-line $line --line-range $start:$end --paging never "$file"
      '';
    in
    {
      home.packages = with pkgs; [
        fzfBatPreview
        resvg
        ueberzugpp
        ffmpegthumbnailer
        ripdrag
        trash-cli
        ouch
        glow
        plocate
      ];

      home.sessionVariables = {
        YAZI_ZOXIDE_OPTS = "--height=70% --margin=2% --padding=1% --border=sharp --info=default --layout=default --no-preview --ansi --no-sort";
      };

      programs.yazi = {
        enable = true;
        enableZshIntegration = false;

        theme = {
          indicator = {
            padding = {
              open = "█";
              close = "█";
            };
          };
        };

        plugins = {
          # nixpkgs plugins
          relative-motions = pkgs.yaziPlugins.relative-motions;
          bookmarks = pkgs.yaziPlugins.bookmarks;
          full-border = pkgs.yaziPlugins.full-border;
          smart-enter = pkgs.yaziPlugins.smart-enter;
          toggle-pane = pkgs.yaziPlugins.toggle-pane;
          piper = pkgs.yaziPlugins.piper;
          chmod = pkgs.yaziPlugins.chmod;
          # local custom plugins
          search = ./yazi/plugins/search.yazi;
          searchjump = ./yazi/plugins/searchjump.yazi;
        };

        initLua = ''
          require("full-border"):setup({ type = ui.Border.PLAIN })
          require("relative-motions"):setup({ show_numbers = "relative", show_motion = true })
          require("bookmarks"):setup({
            persist = "vim",
            notify = { enable = false },
          })
          require("searchjump"):setup({
            only_current = true,
            unmatch_fg = "reset",
            match_str_fg = "reset",
            match_str_bg = "reset",
            first_match_str_fg = "reset",
            first_match_str_bg = "reset",
            label_fg = "#000000",
            label_bg = "#CCFF88",
          })

          -- Fix: relative-motions number bg doesn't match entity bg because
          -- entity spans explicitly reset their background, overriding the
          -- line-level style. Explicitly apply entity:style() to the number
          -- span so both have the same background.
          local _rm_current_redraw = Current.redraw
          Current.redraw = function(self)
            local files = self._folder.window
            if #files == 0 then return self:empty() end

            local hovered_index
            for i, f in ipairs(files) do
              if f.is_hovered then
                hovered_index = i
                break
              end
            end

            local entities, linemodes = {}, {}
            for i, f in ipairs(files) do
              linemodes[#linemodes + 1] = Linemode:new(f):redraw()
              local entity = Entity:new(f)
              local style = entity:style()
              local num = Entity:number(i, #self._folder.files, f, hovered_index)
              entities[#entities + 1] = ui.Line({ num:style(style), entity:redraw() }):style(style)
            end

            return {
              ui.List(entities):area(self._area),
              ui.Text(linemodes):area(self._area):align(ui.Align.RIGHT),
            }
          end
        '';

        keymap = {
          mgr.prepend_keymap = [
            # --- quit / escape ---
            {
              on = "<Esc>";
              run = "escape --all";
              desc = "Exit visual mode, clear selection, or cancel search";
            }
            {
              on = "q";
              run = "quit";
              desc = "Quit";
            }
            {
              on = "<C-c>";
              run = "close";
              desc = "Close tab, or quit if last";
            }
            {
              on = "<C-z>";
              run = "noop";
              desc = "noop";
            }

            # --- navigation ---
            {
              on = "l";
              run = "plugin smart-enter";
              desc = "Enter dir or open file";
            }
            {
              on = "J";
              run = "arrow 5";
              desc = "Move cursor down 5 lines";
            }
            {
              on = "K";
              run = "arrow -5";
              desc = "Move cursor up 5 lines";
            }
            {
              on = "<C-o>";
              run = "back";
              desc = "Back to previous directory";
            }
            {
              on = "<C-i>";
              run = "forward";
              desc = "Forward to next directory";
            }

            # --- selection ---
            {
              on = "v";
              run = [
                "toggle"
                "arrow 1"
              ];
              desc = "Toggle selection and advance";
            }
            {
              on = "V";
              run = "visual_mode";
              desc = "Enter visual mode";
            }
            {
              on = [
                "u"
                "v"
              ];
              run = "visual_mode --unset";
              desc = "Enter visual mode (unset)";
            }

            # --- open ---
            {
              on = "o";
              run = "open --interactive";
              desc = "Open selected files interactively";
            }

            # --- yank / cut / paste (vim-style) ---
            {
              on = [
                "y"
                "y"
              ];
              run = "yank";
              desc = "Yank selected files";
            }
            {
              on = [
                "d"
                "d"
              ];
              run = "yank --cut";
              desc = "Cut selected files";
            }
            {
              on = [
                "p"
                "p"
              ];
              run = "paste";
              desc = "Paste yanked files";
            }
            {
              on = [
                "u"
                "y"
              ];
              run = "unyank";
              desc = "Cancel yank";
            }
            {
              on = "D";
              run = "shell 'trash-put \"$@\"'";
              desc = "Trash selected files";
            }

            # --- rename ---
            {
              on = "r";
              run = "rename --cursor=before_ext";
              desc = "Rename (cursor before ext)";
            }
            {
              on = "R";
              run = "rename --cursor=after_ext";
              desc = "Rename (cursor after ext)";
            }

            # --- copy paths ---
            {
              on = [
                "y"
                "p"
              ];
              run = "copy path";
              desc = "Copy file path";
            }
            {
              on = [
                "y"
                "n"
              ];
              run = "copy filename";
              desc = "Copy filename";
            }
            {
              on = [
                "y"
                "N"
              ];
              run = "copy name_without_ext";
              desc = "Copy filename without extension";
            }

            # --- tabs ---
            {
              on = "<C-t>";
              run = "tab_create --current";
              desc = "Create new tab";
            }
            {
              on = [
                "<C-w>"
                "n"
              ];
              run = "tab_create --current";
              desc = "Create new tab";
            }
            {
              on = [
                "<C-w>"
                "c"
              ];
              run = "close";
              desc = "Close current tab";
            }
            {
              on = [
                "<C-w>"
                "h"
              ];
              run = "tab_switch -1 --relative";
              desc = "Previous tab";
            }
            {
              on = [
                "<C-w>"
                "l"
              ];
              run = "tab_switch 1 --relative";
              desc = "Next tab";
            }
            {
              on = [
                "<C-w>"
                "1"
              ];
              run = "tab_switch 0";
              desc = "Switch to tab 1";
            }
            {
              on = [
                "<C-w>"
                "2"
              ];
              run = "tab_switch 1";
              desc = "Switch to tab 2";
            }
            {
              on = [
                "<C-w>"
                "3"
              ];
              run = "tab_switch 2";
              desc = "Switch to tab 3";
            }
            {
              on = [
                "<C-w>"
                "4"
              ];
              run = "tab_switch 3";
              desc = "Switch to tab 4";
            }
            {
              on = [
                "<C-w>"
                "5"
              ];
              run = "tab_switch 4";
              desc = "Switch to tab 5";
            }
            {
              on = [
                "<C-w>"
                "6"
              ];
              run = "tab_switch 5";
              desc = "Switch to tab 6";
            }
            {
              on = [
                "<C-w>"
                "7"
              ];
              run = "tab_switch 6";
              desc = "Switch to tab 7";
            }
            {
              on = [
                "<C-w>"
                "8"
              ];
              run = "tab_switch 7";
              desc = "Switch to tab 8";
            }
            {
              on = [
                "<C-w>"
                "9"
              ];
              run = "tab_switch 8";
              desc = "Switch to tab 9";
            }

            # --- tasks ---
            {
              on = [
                "<Space>"
                "t"
              ];
              run = "tasks:show";
              desc = "Show task manager";
            }

            # --- search ---
            {
              on = "f";
              run = "plugin search 'fzf_content'";
              desc = "Find contents (fzf)";
            }
            {
              on = "<C-f>";
              run = "plugin search 'fzf_filename'";
              desc = "Find filenames (fzf)";
            }
            {
              on = [
                "z"
                "<C-f>"
              ];
              run = "search --via=fd";
              desc = "Find filenames (flat fd)";
            }
            {
              on = "F";
              run = "plugin search 'ripgrep_content'";
              desc = "Find contents (ripgrep)";
            }
            {
              on = [
                "z"
                "F"
              ];
              run = "search --via=rg";
              desc = "Find contents (flat rg)";
            }
            {
              on = [
                "z"
                "/"
              ];
              run = "filter --smart";
              desc = "Filter files";
            }
            {
              on = [
                "z"
                "f"
              ];
              run = "plugin search 'fzf_locate'";
              desc = "Find filenames globally (plocate)";
            }

            # --- jump ---
            {
              on = "s";
              run = "plugin searchjump";
              desc = "EasyMotion-style jump";
            }
            {
              on = "<C-g>";
              run = "plugin zoxide";
              desc = "Jump with zoxide";
            }

            # --- bookmarks (vim marks) ---
            {
              on = "m";
              run = "plugin bookmarks save";
              desc = "Set bookmark";
            }
            {
              on = "'";
              run = "plugin bookmarks jump";
              desc = "Jump to bookmark";
            }
            {
              on = [
                "b"
                "d"
              ];
              run = "plugin bookmarks delete";
              desc = "Delete bookmark";
            }

            # --- relative motions ---
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

            # --- actions ---
            {
              on = [
                "<Space>"
                "m"
              ];
              run = "plugin toggle-pane max-preview";
              desc = "Maximize/restore preview pane";
            }
            {
              on = [
                "<Space>"
                "r"
              ];
              run = "shell 'ripdrag --all-compact --and-exit \"$@\"'";
              desc = "Drag and drop selected files";
            }
            {
              on = [
                "<Space>"
                "q"
              ];
              run = "quit";
              desc = "Quit";
            }
            {
              on = [
                "<Space>"
                "X"
              ];
              run = "plugin chmod";
              desc = "chmod selected files";
            }
            {
              on = [
                "<Space>"
                "o"
                "c"
              ];
              run = "shell 'ouch compress \"$@\" archive.zip'";
              desc = "Compress selected files";
            }
            {
              on = [
                "<Space>"
                "o"
                "d"
              ];
              run = "shell 'ouch decompress \"$@\"'";
              desc = "Decompress selected files";
            }
            {
              on = "<C-q>";
              run = "shell --block lazygit";
              desc = "Run lazygit";
            }

            # --- goto ---
            {
              on = [
                "g"
                "m"
              ];
              run = "cd /run/media/chek";
              desc = "Go to mounted drives";
            }
            {
              on = [
                "g"
                "?"
              ];
              run = "help";
              desc = "Open help";
            }
          ];

          tasks.prepend_keymap = [
            {
              on = "q";
              run = "close";
              desc = "Close task manager";
            }
            {
              on = [
                "g"
                "?"
              ];
              run = "help";
              desc = "Open help";
            }
          ];

          spot.prepend_keymap = [
            {
              on = [
                "y"
                "y"
              ];
              run = "copy cell";
              desc = "Copy selected cell";
            }
            {
              on = [
                "g"
                "?"
              ];
              run = "help";
              desc = "Open help";
            }
          ];

          pick.prepend_keymap = [
            {
              on = [
                "g"
                "?"
              ];
              run = "help";
              desc = "Open help";
            }
          ];

          input.prepend_keymap = [
            {
              on = [
                "g"
                "?"
              ];
              run = "help";
              desc = "Open help";
            }
          ];

          confirm.prepend_keymap = [
            {
              on = [
                "g"
                "?"
              ];
              run = "help";
              desc = "Open help";
            }
          ];

          cmp.prepend_keymap = [
            {
              on = "<Esc>";
              run = "close";
              desc = "Cancel completion";
            }
            {
              on = [
                "g"
                "?"
              ];
              run = "help";
              desc = "Open help";
            }
          ];

          help.prepend_keymap = [
            {
              on = "q";
              run = "close";
              desc = "Hide help";
            }
            {
              on = "/";
              run = "filter";
              desc = "Filter help items";
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
            sort_by = "natural";
            linemode = "size";
            show_hidden = true;
          };

          preview = {
            max_width = 1920;
            max_height = 1080;
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

          plugin = {
            prepend_previewers = [
              {
                mime = "video/*";
                run = "noop";
              }
              {
                url = "*.tar*";
                run = ''piper --format=url -- tar tf "$1"'';
              }
              {
                url = "*.csv";
                run = ''piper -- bat -p --color=always "$1"'';
              }
              {
                url = "*.md";
                run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
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
