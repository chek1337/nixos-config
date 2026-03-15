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
            extraConfig = ''
              set -g @sessionx-tmuxinator-mode 'on'
              set -g @sessionx-zoxide-mode 'on'
              set -g @sessionx-git-branch 'on'
              set -g @sessionx-filter-current 'false'
              set -g @sessionx-window-height '95%'
              set -g @sessionx-window-width '95%'
              set -g @sessionx-preview-location 'top'
              set -g @sessionx-preview-ratio '65%'
              set -g @sessionx-layout 'reverse'
              set -g @sessionx-bind 's'
              set -g @sessionx-bind-tmuxinator-list 'ctrl-/'
              bind S choose-tree -Zs
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
            bind | split-window -h
            bind - split-window -v

            # Границы панелей
            set -g pane-border-style "fg=${c.base03},bg=default"
            set -g pane-active-border-style "fg=${c.base0D},bg=default"

            # Статусбар
            set -g status-style "bg=${c.base00},fg=${c.base04}"
            set -g status-bg "${c.base00}"
            set -g status-left-length 4
            set -g status-right-length 44

            # Сбрасываем стили окон
            set -g window-status-style "bg=${c.base00},fg=${c.base00}"
            set -g window-status-current-style "bg=${c.base00},fg=${c.base00}"

            # Слева: отступ
            set -g status-left " "

            # Справа: имя сессии в капсуле + отступ
            set -g status-right "#[fg=${c.base0D},bg=${c.base00}]\ue0b6#[fg=${c.base00},bg=${c.base0D},bold] #S #[fg=${c.base0D},bg=${c.base00}]\ue0b4 "

            # Обычное окно
            set -g window-status-format "#[fg=${c.base02},bg=${c.base00}]\ue0b6#[fg=${c.base04},bg=${c.base02}] #I #W #[fg=${c.base02},bg=${c.base00}]\ue0b4"

            # Активное окно
            set -g window-status-current-format "#[fg=${c.base0D},bg=${c.base00}]\ue0b6#[fg=${c.base00},bg=${c.base0D},bold] #I #W#{?window_zoomed_flag, ,} #[fg=${c.base0D},bg=${c.base00}]\ue0b4"

            # Пробел между окнами
            set -g window-status-separator " "

            # Стиль сообщений
            set -g message-style "fg=${c.base0D},bg=${c.base02},bold"
            set -g message-command-style "fg=${c.base05},bg=${c.base02}"
          '';
      };
      home.packages = [ pkgs.tmuxinator ];
    };
}
