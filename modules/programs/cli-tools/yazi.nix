{ ... }:
{
  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";

        plugins = {
          piper = pkgs.yaziPlugins.piper;
          relative-motions = pkgs.yaziPlugins.relative-motions;
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
            output = "{strip_ansi|split:\\::..2}"

            [preview]
            command = "bat -n --color=always '{strip_ansi|split:\\::0}'"
            env = { BAT_THEME = "ansi" }
            offset = '{strip_ansi|split:\\::1}'
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
              {
                url = "*.csv";
                run = ''piper -- bat -p --color=always "$1"'';
              }
              {
                url = "*.md";
                run = ''piper -- env CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
              }
              {
                url = "*/";
                run = ''piper -- eza -TL=3 --color=always --icons=always --group-directories-first --no-quotes "$1"'';
              }
              {
                url = "*.tar*";
                run = ''piper --format=url -- tar tf "$1"'';
              }
              {
                url = "*.zip";
                run = ''piper --format=url -- unzip -Z1 "$1"'';
              }
              {
                mime = "application/sqlite3";
                run = ''piper -- sqlite3 "$1" ".schema --indent"'';
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
