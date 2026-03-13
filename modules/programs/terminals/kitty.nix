{ inputs, ... }:
{
  flake.modules.homeManager.kitty =
    { pkgs, lib, ... }:
    let
      # Fix for: Freeze after entering search mode in less #9416
      # https://github.com/kovidgoyal/kitty/issues/9416
      pkgsLess685 = import inputs.nixpkgs-less-685 { inherit (pkgs) system; };

      kitty-session = pkgs.buildGoModule {
        pname = "kitty-session";
        version = "unstable-5e975c0";
        src = inputs.kitty-session;
        proxyVendor = true;
        vendorHash = "sha256-aewfTkFkRjxwwDL+ik1XMzkB+H54TABa/rVOXFfbtYk=";
        doCheck = false;
        postPatch = ''
          substituteInPlace internal/tui/styles.go \
            --replace '"#7571F9"' '"#81A1C1"' \
            --replace '"#02BF87"' '"#A3BE8C"' \
            --replace '"#FFBF00"' '"#EBCB8B"' \
            --replace '"#636363"' '"#4C566A"' \
            --replace '"#ED567A"' '"#BF616A"' \
            --replace '"#FFFDF5"' '"#ECEFF4"' \
            --replace '"#C1C6B2"' '"#D8DEE9"'
        '';

        meta = {
          description = "Kitty Claude Session Manager";
          homepage = "https://github.com/mad01/kitty-session";
          license = lib.licenses.mit;
          mainProgram = "ks";
        };
      };

    in
    {
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
          tab_bar_min_tabs = 1;
          scrollback_lines = 10000;
          # kitty-scrollback
          allow_remote_control = "socket-only";
          listen_on = "unix:/tmp/kitty";
          shell_integration = "enabled";
        };
        extraConfig = ''
          # kitty-scrollback.nvim Kitten alias
          action_alias kitty_scrollback_nvim kitten '/home/chek/.local/share/nvim/lazy/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py'

          # Browse scrollback buffer in nvim
          map kitty_mod+h kitty_scrollback_nvim

          # Browse output of the last shell command in nvim
          map kitty_mod+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output

          # Show clicked command output in nvim
          mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output
        '';
      };

      programs.zsh.initContent = ''
        repo() { local d=$(ks repo); [[ -n "$d" ]] && cd "$d"; }
      '';

      home.packages = [
        pkgsLess685.less
        kitty-session
      ];

      home.file.".config/ks/config.yaml".text = ''
        dirs:
          - ~/code
      '';
    };
}
