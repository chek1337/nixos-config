{ config, inputs, ... }:
{
  flake.modules.homeManager.kitty =
    { pkgs, config, ... }:
    let
      username = config.home.username;
      # Fix for: Freeze after entering search mode in less #9416
      # https://github.com/kovidgoyal/kitty/issues/9416
      pkgsLess685 = import inputs.nixpkgs-less-685 { inherit (pkgs) system; };
    in
    {
      imports = with config.flake.modules.homeManager; [
        # ks
        # kitty-zoxide-sessions
      ];

      programs.kitty = {
        enable = true;
        settings = {
          confirm_os_window_close = 0;
          cursor_trail = 1;
          enable_audio_bell = false;
          # window_padding_width = "0 8";
          tab_bar_edge = "top";
          tab_bar_style = "powerline";
          tab_powerline_style = "round";
          # tab_bar_min_tabs = 1;
          scrollback_lines = 10000;
          # kitty-scrollback
          allow_remote_control = "socket-only";
          listen_on = "unix:/tmp/kitty";
          shell_integration = "enabled";
        };
        extraConfig = ''
          # Ctrl+Backspace → delete word (works in zsh, nvim, and through tmux)
          map ctrl+backspace send_text all \x17

          # kitty-scrollback.nvim Kitten alias
          action_alias kitty_scrollback_nvim kitten '/home/${username}/.local/share/nvim/lazy/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py'

          # Browse scrollback buffer in nvim
          map kitty_mod+h kitty_scrollback_nvim

          # Browse output of the last shell command in nvim
          map kitty_mod+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output

          # Show clicked command output in nvim
          mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output

          # Hints with letters instead of numbers
          map kitty_mod+e kitten hints --alphabet abcdefghijklmnopqrstuvwxyz
          map kitty_mod+p>f kitten hints --alphabet abcdefghijklmnopqrstuvwxyz --type path
          map kitty_mod+p>l kitten hints --alphabet abcdefghijklmnopqrstuvwxyz --type line
          map kitty_mod+p>w kitten hints --alphabet abcdefghijklmnopqrstuvwxyz --type word --program @
          map kitty_mod+p>h kitten hints --alphabet abcdefghijklmnopqrstuvwxyz --type hash --program @
        '';
      };

      home.sessionVariables = {
        TERMINAL = "kitty";
      };

      home.packages = [ pkgsLess685.less ];
    };
}
