{ inputs, ... }:
let
  darken = inputs.nix-colorizer.hex.darken;
in
{
  flake.modules.homeManager.tmux-theme =
    { config, ... }:
    {
      stylix.targets.tmux.enable = false;

      programs.tmux.extraConfig =
        let
          c = config.lib.stylix.colors.withHashtag;
        in
        ''
          # Границы панелей
          set -g pane-border-style "fg=${c.base03},bg=default"
          set -g pane-active-border-style "fg=${c.base0D},bg=default"

          # Стиль сообщений
          set -g message-style "fg=${c.base0D},bg=${c.base02},bold"
          set -g message-command-style "fg=${c.base05},bg=${c.base02}"

          # Стиль popup-окон
          set -g popup-style "bg=${c.base00}"
          set -g popup-border-style "fg=${c.base0D},bg=${c.base00}"

          # Цвет полосы выбора
          set -g mode-style "bg=${c.base0A},fg=${c.base00},bold"

          # -------------------------------------------------------
          # Nord override для catppuccin
          # -------------------------------------------------------
          set -g @thm_bg        "${c.base00}"
          set -g @thm_mantle    "${c.base00}"
          set -g @thm_crust     "${c.base00}"
          set -g @thm_surface_0 "${c.base01}"
          set -g @thm_surface_1 "${c.base02}"
          set -g @thm_surface_2 "${c.base03}"
          set -g @thm_overlay_0 "${c.base03}"
          set -g @thm_overlay_1 "${c.base03}"
          set -g @thm_overlay_2 "${c.base04}"
          set -g @thm_subtext_0 "${c.base04}"
          set -g @thm_subtext_1 "${c.base05}"
          set -g @thm_fg        "${c.base05}"
          set -g @thm_text      "${c.base06}"
          set -g @thm_rosewater "${c.base06}"
          set -g @thm_teal      "${c.base0C}"
          set -g @thm_sky       "${c.base0C}"
          set -g @thm_sapphire  "${c.base0C}"
          set -g @thm_blue      "${c.base0D}"
          set -g @thm_lavender  "${c.base0D}"
          set -g @thm_red       "${c.base08}"
          set -g @thm_maroon    "${c.base08}"
          set -g @thm_flamingo  "${c.base08}"
          set -g @thm_peach     "${c.base09}"
          set -g @thm_yellow    "${c.base0A}"
          set -g @thm_green     "${c.base0B}"
          set -g @thm_mauve     "${c.base0E}"
          set -g @thm_pink      "${c.base0E}"

          set -g status-style "bg=${darken c.base00 0.12},fg=${c.base04}"
          set -g status-bg    "${darken c.base00 0.12}"
          set -g status-fg    "${c.base04}"

          set -g window-status-separator ""

          # Zoom indicator (styled to match catppuccin modules)
          set -g @catppuccin_zoom_module "#[fg=${c.base0A}]#{@catppuccin_status_left_separator}#[fg=${c.base00},bg=${c.base0A}]󰁌 #[fg=${c.base04},bg=#{E:@catppuccin_status_module_text_bg}] zoom #[fg=#{E:@catppuccin_status_module_text_bg},bg=default]#{@catppuccin_status_right_separator}"
          set -g status-right "#{?window_zoomed_flag,#{E:@catppuccin_zoom_module},}#{E:@catppuccin_status_session}"
        '';
    };
}
