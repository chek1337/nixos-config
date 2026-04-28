{
  flake.modules.homeManager.rice =
    {
      config,
      lib,
      pkgs-stable,
      ...
    }:
    let
      c = config.lib.stylix.colors;
      riceTerminals = pkgs-stable.writeShellScript "rice-terminals" ''
        ${pkgs-stable.alacritty}/bin/alacritty --class rice-nitch --title "nitch" \
          -e bash -c 'clear; ${pkgs-stable.nitch}/bin/nitch; read -r _' &
        sleep 0.3
        ${pkgs-stable.alacritty}/bin/alacritty --class rice-lava --title "lavat" \
          -e bash -c 'while true; do ${pkgs-stable.lavat}/bin/lavat -g -G -c ${c.base0D-hex} -k ${c.base0E-hex} -R 2; done' &
        sleep 0.3
        ${pkgs-stable.alacritty}/bin/alacritty --class rice-nvim --title "nixos" \
          -e bash -c 'PATH="${pkgs-stable.tmux}/bin:${pkgs-stable.tmuxinator}/bin:$PATH" ${pkgs-stable.tmuxinator}/bin/tmuxinator start rice' &
      '';
    in
    lib.mkIf config.settings.enableRice {
      services.niri = {
        spawnAtStartup = [ "${riceTerminals}" ];
        windowRules = [
          ''
            window-rule {
                match app-id="rice-nvim"
                open-floating true
                open-on-workspace "1"
                default-column-width { fixed 630; }
                default-window-height { fixed 970; }
                default-floating-position relative-to="top-left" x=40 y=40
            }
          ''
          ''
            window-rule {
                match app-id="rice-nitch"
                open-floating true
                open-on-workspace "1"
                default-column-width { fixed 320; }
                default-window-height { fixed 375; }
                default-floating-position relative-to="top-right" x=40 y=40
            }
          ''
          ''
            window-rule {
                match app-id="rice-lava"
                open-floating true
                open-on-workspace "1"
                default-column-width { fixed 1170; }
                default-window-height { fixed 250; }
                default-floating-position relative-to="bottom-left" x=710 y=40
            }
          ''
        ];
      };
    };
}
