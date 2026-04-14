{ inputs, ... }:
let
  darken = inputs.nix-colorizer.hex.darken;
in
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
          {
            plugin = fingers;
            extraConfig = ''
              set -g @fingers-key none
              set -g @fingers-main-action 'echo -n {} | wl-copy'
              set -g @fingers-pattern-word '\S+'
              set -g @fingers-pattern-line '.+'
              bind f switch-client -T fingers-mode
              bind F command-prompt "find-window -Z -- '%%'"
              bind f run -b "#{@fingers-cli} start #{pane_id} --mode jump --patterns ip,uuid,sha,digit,url,path,hex,kubernetes,git-status,git-status-branch,diff,word"
            '';
            # bind -T fingers-mode f run -b "#{@fingers-cli} start #{pane_id} --patterns ip,uuid,sha,digit,url,path,hex,kubernetes,git-status,git-status-branch,diff"
            # bind -T fingers-mode w run -b "#{@fingers-cli} start #{pane_id} --patterns word"
            # bind -T fingers-mode l run -b "#{@fingers-cli} start #{pane_id} --patterns line"
          }
          # resurrect
          # {
          #   plugin = continuum;
          #   extraConfig = ''
          #     set -g @continuum-restore 'on'
          #     set -g @continuum-save-interval '10'
          #   '';
          # }
          {
            plugin = tmux-floax;
            extraConfig = ''
              set -g @floax-bind 'p'
              set -g @floax-bind-menu 'P'
              set -g @floax-width '80%'
              set -g @floax-height '80%'
              set -g @floax-border-color '${config.lib.stylix.colors.withHashtag.base0D}'
              set -g @floax-text-color '${config.lib.stylix.colors.withHashtag.base05}'
              set -g @floax-change-path 'false'
              set -g @floax-title 'PopupSession'
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

            # Vi-like copy mode
            bind -T copy-mode-vi v   send -X begin-selection
            bind -T copy-mode-vi V   send -X select-line
            bind -T copy-mode-vi C-v send -X rectangle-toggle
            bind -T copy-mode-vi y   send -X copy-pipe-and-cancel "wl-copy"
            bind -T copy-mode-vi Y   send -X copy-end-of-line \; run "tmux save-buffer - | wl-copy"

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

            set -g status-style "bg=${darken c.base00 0.12},fg=${c.base04}"
            set -g status-bg    "${darken c.base00 0.12}"
            set -g status-fg    "${c.base04}"

            set -g window-status-separator ""

            # Zoom indicator (styled to match catppuccin modules)
            set -g @catppuccin_zoom_module "#[fg=${c.base0A}]#{@catppuccin_status_left_separator}#[fg=${c.base00},bg=${c.base0A}]󰁌 #[fg=${c.base04},bg=#{E:@catppuccin_status_module_text_bg}] zoom #[fg=#{E:@catppuccin_status_module_text_bg},bg=default]#{@catppuccin_status_right_separator}"
            set -g status-right "#{?window_zoomed_flag,#{E:@catppuccin_zoom_module},}#{E:@catppuccin_status_session}"

            # Sesh session manager (via television)
            bind s display-popup -E -w 80% -h 80% -d '#{pane_current_path}' -T 'Sesh' 'tv sesh'
            bind S choose-tree -Zs
            bind -N "last-session (skip scratch)" L run-shell "tmux-last"

            unbind d
            bind D detach-client
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

      home.packages = [
        pkgs.tmuxinator
        pkgs.sesh
        (pkgs.writeShellScriptBin "tmux-last" ''
          current=$(tmux display-message -p '#S')
          tmux list-sessions -F '#{session_last_attached} #{session_name}' \
            | sort -rn \
            | awk -v cur="$current" '$2 != "scratch" && $2 != cur {print $2; exit}' \
            | xargs -I{} tmux switch-client -t {}
        '')
      ];

      xdg.configFile."sesh/sesh.toml".text = ''
        sort_order = ["tmuxinator", "config", "tmux", "zoxide"]
        blacklist = ["scratch"]
      '';

      xdg.configFile."tmuxinator/rice.yml".text = ''
        name: rice
        root: /etc/nixos

        windows:
          - editor:
              panes:
                - nvim /etc/nixos/configuration.nix
          - shell:
              panes:
                -
      '';

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
