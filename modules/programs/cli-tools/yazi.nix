{ ... }:
{
  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";

        plugins = {
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
                ya.emit("plugin", { "television", args = "--text" })
                return
              end

              local tmp_list = os.tmpname()
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
            name = "Yazi Selection Grep"
            description = "Grep in yazi-selected files"

            [source]
            command = "rg --with-filename --line-number --no-heading --color=always . --file-list %s"
            output = "{}"

            [preview]
            command = "bat --style=numbers --color=always --highlight-line {2} {1}"
            ]], tmp_list))
              cf:close()

              local tmp_out = os.tmpname()
              local permit = ui.hide()
              local child = Command("sh")
                :arg("-c")
                :arg(string.format(
                  "tv --no-remote --keybindings 'enter=\"confirm_selection\"' 'Yazi Selection Grep' > %q",
                  tmp_out
                ))
                :cwd(state.cwd)
                :stdin(Command.INHERIT)
                :stdout(Command.INHERIT)
                :stderr(Command.INHERIT)
                :spawn()
              if child then child:wait() end
              permit:drop()

              local of = io.open(tmp_out, "r")
              if of then
                local line = of:read("*all"):gsub("[\r\n]+$", "")
                of:close()
                os.remove(tmp_out)
                if line ~= "" then
                  local file = line:match("^(.+):%d+:")
                  if file then
                    ya.emit("reveal", { Url(file), raw = true })
                  end
                end
              end
              os.remove(tmp_list)
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
            run = "plugin television";
            desc = "Find files (television)";
          }
          {
            on = [
              "<Space>"
              "s"
              "g"
            ];
            run = "plugin television --text";
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
