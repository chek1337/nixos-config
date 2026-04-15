{ pkgs, config }:
let
  c = config.lib.stylix.colors.withHashtag;
in
{
  plugin = pkgs.tmuxPlugins.catppuccin;
  extraConfig = ''
    set -g @catppuccin_flavor "mocha"
    set -g @catppuccin_window_status_style "basic"

    set -g @catppuccin_window_number_color "${c.base03}"
    set -g @catppuccin_window_current_number_color "#{@thm_blue}"

    set -g @catppuccin_window_text " #W"
    set -g @catppuccin_window_current_text " #W"

    set -g @catppuccin_status_module_bg_color "${c.base01}"

    set -g @catppuccin_status_left_separator "█"
    set -g @catppuccin_status_right_separator "█"

    set -g status-left-length 100
    set -g status-right-length 100
    set -g status-left ""

  '';
}
