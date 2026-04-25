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
