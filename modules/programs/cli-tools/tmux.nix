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
        prefix = "C-Space";

        plugins = with pkgs.tmuxPlugins; [
          resurrect
          {
            plugin = continuum;
            extraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '10'
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
    };
}
