{
  flake.modules.homeManager.tmux-sesh =
    { pkgs, ... }:
    let
      seshIcon = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/joshmedeski/sesh/main/sesh-icon.png";
        hash = "sha256-8o8p91OUzYTBx75qAfAS6UDiqKXsQwJ2Fm59eLaRECE=";
      };
    in
    {
      xdg.desktopEntries.sesh = {
        name = "Sesh";
        genericName = "Tmux session picker";
        comment = "Pick a tmux session via television";
        exec = "${pkgs.kitty}/bin/kitty ${pkgs.television}/bin/tv sesh";
        icon = "${seshIcon}";
        terminal = false;
        categories = [
          "System"
          "TerminalEmulator"
        ];
      };

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
        pkgs.sesh
        (pkgs.writeShellScriptBin "tmux-last" ''
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
