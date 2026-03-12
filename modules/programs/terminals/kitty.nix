{ inputs, ... }:
{
  flake.modules.homeManager.kitty =
    { pkgs, ... }:
    let
      # Fix for: Freeze after entering search mode in less #9416
      # https://github.com/kovidgoyal/kitty/issues/9416
      pkgsLess685 = import inputs.nixpkgs-less-685 {
        inherit (pkgs) system; # Берем систему из текущего pkgs
      };
    in
    {
      programs.kitty = {
        enable = true;
        settings = {
          confirm_os_window_close = 0;
          cursor_trail = 1;
          enable_audio_bell = false;
          window_padding_width = "0 8";
        };
      };

      home.packages = [ pkgsLess685.less ];
    };
}
