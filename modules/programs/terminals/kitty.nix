{
  flake.modules.homeManager.kitty =
    { ... }:
    {
      programs.kitty = {
        enable = true;
        settings = {
          confirm_os_window_close = 0;
          window_padding_width = "0 8";
          # hide_window_decorations = true;
          cursor_trail = 1;
          enable_audio_bell = false;
        };
        environment = {
          TERM = "xterm-256color";
        };
      };
    };
}
