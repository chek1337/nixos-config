{
  flake.modules.homeManager.zellij =
    { pkgs, ... }:
    {
      programs.zellij = {
        enable = true;
      };

      xdg.configFile."zellij/config.kdl".text = ''
        default_shell "${pkgs.zsh}/bin/zsh"
        scroll_buffer_size 10000
        mouse_mode true
      '';

      xdg.configFile."zellij/layouts/default.kdl".text = ''
        layout {
            default_tab_template {
                pane size=1 borderless=true {
                    plugin location="zellij:tab-bar"
                }
                children
                pane size=2 borderless=true {
                    plugin location="zellij:status-bar"
                }
            }
        }
      '';
    };
}
