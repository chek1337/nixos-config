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
      # Открыть sesh-tv. Внутри floax popup сначала закрыть popup, затем
      # показать picker на origin-клиенте — иначе popup налезает поверх popup.
      # Origin помечается в FLOAX_OPEN_SESSIONS, чтобы возврат через tmux-last
      # автоматически восстановил popup.
      tmuxSesh = pkgs.writeShellScriptBin "tmux-sesh" ''
        current=$(tmux display-message -p '#S')
        self_client=$(tmux display-message -p '#{client_name}')

        base=$(tmux show-option -gqv @floax-session-name)
        base=''${base:-scratch}

        case "$current" in
          "''${base}_"*)
            origin=$(tmux showenv -g ORIGIN_SESSION 2>/dev/null \
              | sed -n 's/^ORIGIN_SESSION=//p')
            [ -n "$origin" ] || origin=''${current#''${base}_}
            origin_client=$(tmux list-clients -t "$origin" \
              -F '#{client_name}' 2>/dev/null | head -1)
            [ -n "$origin_client" ] || origin_client=$self_client

            # Пометить origin для авто-восстановления popup'а при возврате.
            l=$(tmux showenv -g FLOAX_OPEN_SESSIONS 2>/dev/null \
              | sed -n 's/^FLOAX_OPEN_SESSIONS=//p')
            case " $l " in
              *" $origin "*) ;;
              *) tmux setenv -g FLOAX_OPEN_SESSIONS "''${l:+$l }$origin" ;;
            esac

            tmux detach-client
            tmux display-popup -c "$origin_client" -E -w 80% -h 80% \
              -T 'Sesh' -b rounded '${seshTv}/bin/sesh-tv'
            ;;
          *)
            tmux display-popup -E -w 80% -h 80% -d '#{pane_current_path}' \
              -T 'Sesh' -b rounded '${seshTv}/bin/sesh-tv'
            ;;
        esac
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
        bind s run-shell "${tmuxSesh}/bin/tmux-sesh"
        bind S choose-tree -Zs
        bind -N "last-session (skip scratch)" L run-shell "tmux-last"
        # Sesh / sessions (русская раскладка)
        bind ы run-shell "${tmuxSesh}/bin/tmux-sesh"
        bind Ы choose-tree -Zs

        bind -N "last-session (skip scratch)" Д run-shell "tmux-last"
      '';

      home.packages = [
        pkgs.sesh
        seshTv
        tmuxSesh
        (pkgs.writeShellScriptBin "tmux-last" ''
          current=$(tmux display-message -p '#S')
          self_client=$(tmux display-message -p '#{client_name}')

          # floax scratch base name (per-session => <base>_<origin>).
          base=$(tmux show-option -gqv @floax-session-name)
          base=''${base:-scratch}

          # Global set of real sessions whose popup must be restored on return.
          list_get() {
            tmux showenv -g FLOAX_OPEN_SESSIONS 2>/dev/null \
              | sed -n 's/^FLOAX_OPEN_SESSIONS=//p'
          }
          list_has() { case " $(list_get) " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
          list_add() {
            list_has "$1" && return 0
            l=$(list_get)
            tmux setenv -g FLOAX_OPEN_SESSIONS "''${l:+$l }$1"
          }
          list_del() {
            n=""
            for x in $(list_get); do
              [ "$x" = "$1" ] || n="''${n:+$n }$x"
            done
            tmux setenv -g FLOAX_OPEN_SESSIONS "$n"
          }

          last_session() {
            tmux list-sessions -F '#{session_last_attached} #{session_name}' \
              | sort -rn \
              | awk -v cur="$1" -v b="$2" '$2 !~ "^"b"_" && $2 != cur {print $2; exit}'
          }

          # Reopen the floax popup of session $1 over client $2.
          open_popup() {
            sess=$1
            client=$2
            scr="''${base}_$sess"
            if ! tmux has-session -t "$scr" 2>/dev/null; then
              p=$(tmux display -t "$sess" -p '#{pane_current_path}')
              tmux new-session -d -c "$p" -s "$scr"
              tmux set-option -t "$scr" status off
            fi
            w=$(tmux show-option -gqv @floax-width);  w=''${w:-80%}
            h=$(tmux show-option -gqv @floax-height); h=''${h:-80%}
            bc=$(tmux show-option -gqv @floax-border-color)
            tc=$(tmux show-option -gqv @floax-text-color)
            ttl=$(tmux show-option -gqv @floax-title)
            tmux set-option -t "$scr" detach-on-destroy on
            tmux setenv -g ORIGIN_SESSION "$sess"
            set -- -w "$w" -h "$h" -b rounded -E "tmux attach-session -t \"$scr\""
            [ -n "$ttl" ] && set -- -T "$ttl" "$@"
            [ -n "$tc" ] && set -- -s "fg=$tc" "$@"
            [ -n "$bc" ] && set -- -S "fg=$bc" "$@"
            tmux display-popup -c "$client" "$@"
          }

          # Switch $client to last session; if that session is flagged,
          # immediately restore its popup.
          go_last() {
            from=$1
            client=$2
            target=$(last_session "$from" "$base")
            [ -n "$target" ] || return 0
            tmux switch-client -c "$client" -t "$target"
            if list_has "$target"; then
              list_del "$target"
              open_popup "$target" "$client"
            fi
          }

          case "$current" in
            "''${base}_"*)
              # Inside a floax popup: remember it, close it, then switch the
              # origin client (switching this popup client corrupts the overlay).
              origin=$(tmux showenv -g ORIGIN_SESSION 2>/dev/null \
                | sed -n 's/^ORIGIN_SESSION=//p')
              [ -n "$origin" ] || origin=''${current#''${base}_}
              origin_client=$(tmux list-clients -t "$origin" \
                -F '#{client_name}' 2>/dev/null | head -1)
              [ -n "$origin_client" ] || origin_client=$self_client

              list_add "$origin"
              tmux detach-client
              go_last "$origin" "$origin_client"
              ;;
            *)
              go_last "$current" "$self_client"
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
