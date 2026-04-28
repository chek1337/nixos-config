{
  flake.modules.homeManager.tmux-core =
    { pkgs-unstable, ... }:
    {
      programs.tmux = {
        enable = true;
        shell = "${pkgs-unstable.zsh}/bin/zsh";
        terminal = "tmux-256color";
        historyLimit = 10000;
        prefix = "C-Space";
        mouse = true;
        keyMode = "vi";
        extraConfig = ''
          set -g base-index 1
          setw -g pane-base-index 1
          set -g status-position top
          set -g renumber-windows on
          set -g detach-on-destroy off
          set -g escape-time 0
          set -g set-clipboard on
          set -ga terminal-overrides ",xterm-256color:Tc"
          set -as terminal-features ',*:osc133'
        '';
      };

      programs.zsh.shellAliases = {
        tm = "tmux";
        tmn = "tmux new -s";
        tma = "tmux attach -t";
        tml = "tmux list-sessions";
        tmk = "tmux kill-session -t";
        tmK = "tmux kill-server";
      };
    };
}
