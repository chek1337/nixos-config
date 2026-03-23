{
  flake.modules.homeManager.tmux =
    { pkgs, config, ... }:
    {
      stylix.targets.tmux.enable = false;

      programs.tmux = {
        enable = true;
        shell = "${pkgs.zsh}/bin/zsh";
        terminal = "tmux-256color";
        historyLimit = 10000;
        prefix = "C-Space";
        mouse = true;
        keyMode = "vi";
        plugins = with pkgs.tmuxPlugins; [
          resurrect
          {
            plugin = continuum;
            extraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '10'
            '';
          }
          {
            plugin = tmux-floax;
            extraConfig = ''
              set -g @floax-bind 'p'
              set -g @floax-bind-menu 'P'
              set -g @floax-width '80%'
              set -g @floax-height '80%'
              set -g @floax-border-color '${config.lib.stylix.colors.withHashtag.base0D}'
              set -g @floax-text-color '${config.lib.stylix.colors.withHashtag.base05}'
              set -g @floax-change-path 'true'
            '';
          }
          {
            plugin = tmux-sessionx;
            extraConfig =
              let
                c = config.lib.stylix.colors.withHashtag;
              in
              ''
                set -g @sessionx-tmuxinator-mode 'on'
                set -g @sessionx-zoxide-mode 'on'
                set -g @sessionx-git-branch 'on'
                set -g @sessionx-filter-current 'false'
                set -g @sessionx-window-height '95%'
                set -g @sessionx-window-width '95%'
                # set -g @sessionx-preview-enabled 'false'
                set -g @sessionx-preview-location 'top'
                set -g @sessionx-preview-ratio '65%'
                set -g @sessionx-layout 'reverse'
                set -g @sessionx-bind 's'
                set -g @sessionx-bind-tmuxinator-list 'ctrl-/'
                bind S choose-tree -Zs
                set -g @sessionx-custom-paths-subdirectories 'false'

                set -g @sessionx-additional-options "--color=bg:${c.base00},bg+:${c.base01},fg:${c.base04},fg+:${c.base06},hl:${c.base0C},hl+:${c.base0D},border:${c.base03},header:${c.base0B},info:${c.base0A},prompt:${c.base0D},pointer:${c.base08},marker:${c.base0B},spinner:${c.base0C},preview-bg:${c.base00}"
              '';
          }
          {
            plugin = catppuccin;
            extraConfig =
              let
                c = config.lib.stylix.colors.withHashtag;
              in
              ''
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
        ];
        extraConfig =
          let
            c = config.lib.stylix.colors.withHashtag;
          in
          ''
            set -g base-index 1
            setw -g pane-base-index 1
            set -g status-position top
            set -g renumber-windows on
            set -g detach-on-destroy off
            set -g escape-time 0
            set -g set-clipboard on
            set -ga terminal-overrides ",xterm-256color:Tc"

            # Навигация по панелям
            bind h select-pane -L
            bind j select-pane -D
            bind k select-pane -U
            bind l select-pane -R
            # Навигация по панелям (русская раскладка)
            bind р select-pane -L
            bind о select-pane -D
            bind л select-pane -U
            bind д select-pane -R
            bind | split-window -h
            bind - split-window -v

            # Не выходить из copy-mode при отпускании мыши после выделения
            unbind -T copy-mode-vi MouseDragEnd1Pane

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

            set -g status-style "bg=#191c23,fg=${c.base04}"
            set -g status-bg    "#191c23"
            set -g status-fg    "${c.base04}"

            set -g window-status-separator ""

            # Zoom indicator (styled to match catppuccin modules)
            set -g @catppuccin_zoom_module "#[fg=${c.base0A}]#{@catppuccin_status_left_separator}#[fg=${c.base00},bg=${c.base0A}]󰁌 #[fg=${c.base04},bg=#{E:@catppuccin_status_module_text_bg}] zoom #[fg=#{E:@catppuccin_status_module_text_bg},bg=default]#{@catppuccin_status_right_separator}"
            set -g status-right "#{?window_zoomed_flag,#{E:@catppuccin_zoom_module},}#{E:@catppuccin_status_session}"
          '';
      };
      programs.zsh.shellAliases = {
        tm = "tmux";
        tmn = "tmux new -s";
        tma = "tmux attach -t";
        tml = "tmux list-sessions";
        tmk = "tmux kill-session -t";
        tmK = "tmux kill-server";
        tmor = "tmuxinator";
      };

      home.packages = [ pkgs.tmuxinator ];

      xdg.configFile."tmuxinator/nixos-config.yml".text = ''
        name: nixos-config
        root: ~/nixos-config

        windows:
          - shell:
              layout: even-horizontal
              panes:
                - vopono-exec claude
                -
          - editor:
              panes:
                - nvim
      '';
    };
}
