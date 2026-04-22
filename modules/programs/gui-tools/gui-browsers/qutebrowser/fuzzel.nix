{
  flake.modules.homeManager.qutebrowser-fuzzel =
    {
      lib,
      pkgs,
      ...
    }:
    let
      fuzzel = pkgs.fuzzel.overrideAttrs (old: {
        version = "1.14.1";
        src = pkgs.fetchurl {
          url = "https://codeberg.org/dnkl/fuzzel/archive/1.14.1.tar.gz";
          hash = "sha256-xkFnhsOgYAuK2R7ZUcQ8ACpjmHDDgjtKYMkQRC9K4Jc=";
        };
        patches = (old.patches or [ ]) ++ [
          ./fuzzel-word-boundary.patch
          ./fuzzel-smart-execute.patch
        ];
      });

      # Used in bash as a proper array (no word-splitting issues)
      fuzzelStyleArgs = [
        "--background-color=181818ff"
        "--text-color=d4d4d4ff"
        "--input-color=e8e8e8ff"
        "--prompt-color=666666ff"
        "--match-color=5b9bd5ff"
        "--selection-color=2a2a2aff"
        "--selection-text-color=e8e8e8ff"
        "--selection-match-color=7ab8f5ff"
        "--border-color=333333ff"
        "--border-width=1"
        "--border-radius=0"
        "--line-height=16"
        "--width=120"
        "--font=monospace:size=9"
      ];

      # Used in Python via .split() — newline-separated string
      fuzzelStyle = lib.concatStringsSep "\n" fuzzelStyleArgs;

      fuzzelOpen = pkgs.writeShellScriptBin "qute-fuzzel-open" ''
        menu="''${1:-open}"
        action="''${2:-current}"

        readonly FUZZEL="${fuzzel}/bin/fuzzel"
        readonly SQLITE="${pkgs.sqlite}/bin/sqlite3"
        readonly URL_WIDTH=60
        readonly TITLE_WIDTH=50
        readonly FUZZEL_STYLE=(${lib.escapeShellArgs fuzzelStyleArgs})

        fmt_line() {
          local title="$1" url="$2" short_url short_title chars spaces
          if [ "''${#url}" -gt "$URL_WIDTH" ]; then
            short_url="''${url:0:$((URL_WIDTH - 1))}…"
          else
            short_url="$url"
          fi
          if [ "''${#title}" -gt "$TITLE_WIDTH" ]; then
            short_title="''${title:0:$((TITLE_WIDTH - 1))}…"
          else
            short_title="$title"
          fi
          chars=''${#short_url}
          spaces=$((URL_WIDTH - chars))
          printf '%s%*s    %s\n' "$short_url" "$spaces" "" "$short_title"
        }

        show_quickmarks() {
          [ -f "$QUTE_CONFIG_DIR/quickmarks" ] || return
          while read -r name url; do
            fmt_line "[$name]" "$url"
          done < "$QUTE_CONFIG_DIR/quickmarks"
        }

        show_bookmarks() {
          [ -f "$QUTE_CONFIG_DIR/bookmarks/urls" ] || return
          while read -r url title; do
            fmt_line "''${title:-$url}" "$url"
          done < "$QUTE_CONFIG_DIR/bookmarks/urls"
        }

        show_history() {
          "$SQLITE" -separator $'\t' "$QUTE_DATA_DIR/history.sqlite" \
            'SELECT COALESCE(title, url), url FROM CompletionHistory ORDER BY last_atime DESC LIMIT 500' \
            | while IFS=$'\t' read -r title url; do
                fmt_line "$title" "$url"
              done
        }

        menu_open() {
          [ -n "$QUTE_URL" ] && fmt_line "[current]" "$QUTE_URL"
          show_quickmarks
          show_bookmarks
          show_history
        }

        menu_bookmarks() {
          show_quickmarks
          show_bookmarks
        }

        run_fuzzel() {
          local prompt="$1" search="$2"
          local args=(--dmenu --no-sort --match-mode=exact -p "$prompt: " -l 12 "''${FUZZEL_STYLE[@]}")
          [ -n "$search" ] && args+=(--search="$search")
          "$FUZZEL" "''${args[@]}"
        }

        case "$menu" in
          bookmarks) selection=$(menu_bookmarks | run_fuzzel "bookmark" "") ;;
          edit)      selection=$(menu_open      | run_fuzzel "open"     "$QUTE_URL") ;;
          *)         selection=$(menu_open      | run_fuzzel "open"     "") ;;
        esac

        [ -z "$selection" ] && exit 0

        url=$(printf '%s' "$selection" | grep -oE 'https?://\S+' | head -1)
        url="''${url%…}"
        [ -z "$url" ] && url="$selection"
        [ -z "$url" ] && exit 0

        case "$action" in
          tab)     printf 'open -t %s\n' "$url" >> "$QUTE_FIFO" ;;
          window)  printf 'open -w %s\n' "$url" >> "$QUTE_FIFO" ;;
          private) printf 'open -p %s\n' "$url" >> "$QUTE_FIFO" ;;
          *)       printf 'open %s\n'    "$url" >> "$QUTE_FIFO" ;;
        esac
      '';

      fuzzelTabs =
        pkgs.writers.writePython3Bin "qute-fuzzel-tabs"
          {
            libraries = [ pkgs.python3Packages.pyyaml ];
          }
          ''
            import os
            import sys
            import subprocess
            import yaml

            FUZZEL = "${fuzzel}/bin/fuzzel"
            FUZZEL_STYLE = """${fuzzelStyle}""".split()
            TITLE_WIDTH = 45


            def truncate(text, width):
                return text[:width - 1] + '…' if len(text) > width else text


            def build_entries(data):
                entries = []
                for wid, window in enumerate(data.get('windows', [])):
                    for tid, tab in enumerate(window.get('tabs', [])):
                        history = tab.get('history', [])
                        if not history:
                            continue
                        last = history[-1]
                        title = last.get('title') or ""
                        url = last.get('url') or ""
                        active = '* ' if tab.get('active') else '  '
                        prefix = f'[{tid + 1}]{active}'
                        t = truncate(title, TITLE_WIDTH)
                        display = f'{prefix:<8}{t:<{TITLE_WIDTH}}    {url}'
                        line = f'{prefix}\t{display}'
                        entries.append((tid + 1, wid + 1, line))
                return sorted(entries, key=lambda e: e[0])


            def pick_tab(lines):
                proc = subprocess.run(
                    [FUZZEL] + FUZZEL_STYLE + [
                      '--dmenu', '--no-sort', '--match-mode=exact',
                      '--match-nth=1', '--with-nth=2',
                      '-p', 'tab: ', '-l', '12',
                    ],
                    input='\n'.join(lines),
                    capture_output=True,
                    text=True,
                )
                if proc.returncode != 0 or not proc.stdout.strip():
                    return None
                result = proc.stdout.strip()
                if result.startswith('['):
                    return int(result[1:result.index(']')])
                try:
                    return int(result)
                except ValueError:
                    return None


            def main():
                data_dir = os.environ.get('QUTE_DATA_DIR') or ""
                fifo = os.environ.get('QUTE_FIFO') or ""
                session_file = os.path.join(data_dir, 'sessions', '_autosave.yml')

                if not os.path.exists(session_file):
                    sys.exit(1)

                with open(session_file) as f:
                    data = yaml.safe_load(f)

                entries = build_entries(data)
                if not entries:
                    sys.exit(1)

                lines = [e[2] for e in entries]

                tid = pick_tab(lines)
                if tid is None:
                    sys.exit(0)

                with open(fifo, 'a') as f:
                    f.write(f'tab-focus {tid}\n')


            main()
          '';
    in
    {
      home.packages = [
        fuzzelOpen
        fuzzelTabs
      ];

      home.file = {
        ".local/share/qutebrowser/userscripts/qute-fuzzel-open".source =
          "${fuzzelOpen}/bin/qute-fuzzel-open";
        ".local/share/qutebrowser/userscripts/qute-fuzzel-tabs".source =
          "${fuzzelTabs}/bin/qute-fuzzel-tabs";
      };

      programs.qutebrowser.extraConfig = ''
        config.bind("o", "spawn --userscript qute-fuzzel-open open current")
        config.bind("O", "spawn --userscript qute-fuzzel-open open tab")
        config.bind("go", "spawn --userscript qute-fuzzel-open open current")
        config.bind("ge", "spawn --userscript qute-fuzzel-open edit current")
        config.bind("b", "spawn --userscript qute-fuzzel-open bookmarks current")
        config.bind("B", "spawn --userscript qute-fuzzel-open bookmarks tab")
        config.bind("T", "spawn --userscript qute-fuzzel-tabs")
      '';
    };
}
