{
  flake.modules.homeManager.tmux-sesh =
    { pkgs-unstable, ... }:
    {
      programs.tmux.extraConfig = ''
        # Sesh session manager (via television)
        bind s display-popup -E -w 80% -h 80% -d '#{pane_current_path}' -T 'Sesh' -b rounded 'tv sesh'
        bind S choose-tree -Zs
        bind -N "last-session (skip scratch)" L run-shell "tmux-last"
        # Sesh / sessions (русская раскладка)
        bind ы display-popup -E -w 80% -h 80% -d '#{pane_current_path}' -T 'Sesh' -b rounded 'tv sesh'
        bind Ы choose-tree -Zs

        bind -N "last-session (skip scratch)" Д run-shell "tmux-last"
      '';

      home.packages = [
        pkgs-unstable.sesh
        (pkgs-unstable.writeShellScriptBin "tmux-last" ''
          current=$(tmux display-message -p '#S')
          tmux list-sessions -F '#{session_last_attached} #{session_name}' \
            | sort -rn \
            | awk -v cur="$current" '$2 !~ /^scratch_/ && $2 != cur {print $2; exit}' \
            | xargs -I{} tmux switch-client -t {}
        '')
      ];

      xdg.configFile."sesh/sesh.toml".text = ''
        sort_order = ["tmuxinator", "config", "tmux", "zoxide"]
        blacklist = ["^scratch_"]
      '';
    };
}
