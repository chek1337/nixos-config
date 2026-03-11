{ inputs, ... }:
{
  flake.modules.homeManager.kitty =
    { pkgs, ... }:
    let
      # === ИМПОРТ СТАРОЙ ВЕРСИИ NIXPKGS ===
      # Это делается локально, как вы делаете с lazyvim в nvim.nix
      pkgsLess685 = import inputs.nixpkgs-less-685 {
        inherit (pkgs) system; # Берем систему из текущего pkgs
      };
      # ====================================
    in
    {
      programs.kitty = {
        enable = true;
        settings = {
          confirm_os_window_close = 0;
          cursor_trail = 1;
          enable_audio_bell = false;
        };
      };

      # === ДОБАВЛЯЕМ ПАКЕТ ===
      # Теперь этот less будет доступен в kitty и терминале
      home.packages = [ pkgsLess685.less ];
      # =========================

      # Fix for: Freeze after entering search mode in less #9416
      # https://github.com/kovidgoyal/kitty/issues/9416
    };
}
