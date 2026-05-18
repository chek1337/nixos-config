{
  flake.modules.homeManager.tmux-sesh =
    { pkgs, ... }:
    let
      seshIcon = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/joshmedeski/sesh/main/sesh-icon.png";
        hash = "sha256-8o8p91OUzYTBx75qAfAS6UDiqKXsQwJ2Fm59eLaRECE=";
      };
      # television 0.15.6 runs `mode = "execute"` actions with stdio dup'd onto
      # /dev/tty (attach_to_tty in command.rs), and `tmux attach-session`
      # refuses /dev/tty -> "Failed to attach to tmux session: exit status 1"
      # (upstream alexpasmantier/television#1052, sesh #368; fixed upstream,
      # ships in tv 0.15.7 — not yet in nixpkgs). Workaround: use tv purely as
      # a picker (Enter -> stdout) and run `sesh connect` from this wrapper, so
      # it inherits the real pty instead of /dev/tty.
      seshTv = pkgs.writeShellScriptBin "sesh-tv" ''
        sel=$(${pkgs.television}/bin/tv sesh) || exit 0
        [ -n "$sel" ] || exit 0
        exec ${pkgs.sesh}/bin/sesh connect "$sel"
      '';
      seshLauncher = pkgs.writeShellScript "sesh-launcher" ''
        exec ${pkgs.kitty}/bin/kitty \
          ${pkgs.zsh}/bin/zsh -i -c '${seshTv}/bin/sesh-tv; exec ${pkgs.zsh}/bin/zsh -i'
      '';
    in
    {
      xdg.desktopEntries.sesh = {
        name = "Sesh";
        genericName = "Tmux session picker";
        comment = "Pick a tmux session via television";
        exec = "${seshLauncher}";
        icon = "${seshIcon}";
        terminal = false;
        categories = [
          "System"
          "TerminalEmulator"
        ];
      };

      programs.tmux.extraConfig = ''
        # Sesh session manager (via television)
        bind s display-popup -E -w 80% -h 80% -d '#{pane_current_path}' -T 'Sesh' -b rounded '${seshTv}/bin/sesh-tv'
        bind S choose-tree -Zs
        bind -N "last-session (skip scratch)" L run-shell "tmux-last"
        # Sesh / sessions (русская раскладка)
        bind ы display-popup -E -w 80% -h 80% -d '#{pane_current_path}' -T 'Sesh' -b rounded '${seshTv}/bin/sesh-tv'
        bind Ы choose-tree -Zs

        bind -N "last-session (skip scratch)" Д run-shell "tmux-last"
      '';

      home.packages = [
        pkgs.sesh
        seshTv
        (pkgs.writeShellScriptBin "tmux-last" ''
          current=$(tmux display-message -p '#S')

          last_session() {
            tmux list-sessions -F '#{session_last_attached} #{session_name}' \
              | sort -rn \
              | awk -v cur="$1" '$2 !~ /^scratch_/ && $2 != cur {print $2; exit}'
          }

          case "$current" in
            scratch_*)
              # Inside a floax popup: close it, then switch the origin client
              # (switching this popup client would corrupt the overlay).
              origin=$(tmux showenv -g ORIGIN_SESSION 2>/dev/null | cut -d= -f2-)
              [ -n "$origin" ] || origin=''${current#scratch_}
              origin_client=$(tmux list-clients -t "$origin" \
                -F '#{client_name}' 2>/dev/null | head -1)

              tmux detach-client

              target=$(last_session "$origin")
              [ -n "$target" ] || exit 0
              if [ -n "$origin_client" ]; then
                tmux switch-client -c "$origin_client" -t "$target"
              else
                tmux switch-client -t "$target"
              fi
              ;;
            *)
              target=$(last_session "$current")
              [ -n "$target" ] || exit 0
              tmux switch-client -t "$target"
              ;;
          esac
        '')
      ];

      xdg.configFile."sesh/sesh.toml".text = ''
        sort_order = ["tmuxinator", "config", "tmux", "zoxide"]
        blacklist = ["^scratch_"]
      '';
    };
}
