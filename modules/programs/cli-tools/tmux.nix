{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
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
        extraConfig = ''
          set -g base-index 1
          setw -g pane-base-index 1
          set -g status-position top
          set -ga terminal-overrides ",xterm-256color:Tc"
          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R
          bind | split-window -h
          bind - split-window -v
        '';
      };
      home.packages = [ pkgs.tmuxinator ];
    };
}
