{
  flake.modules.homeManager.qutebrowser =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      useFuzzel = true;

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
        mode="''${1:-open}"

        readonly FUZZEL="${fuzzel}/bin/fuzzel"
        readonly SQLITE="${pkgs.sqlite}/bin/sqlite3"
        readonly TITLE_WIDTH=50
        readonly FUZZEL_STYLE=(${lib.escapeShellArgs fuzzelStyleArgs})

        fmt_line() {
          local title="$1" url="$2" short chars spaces
          if [ "''${#title}" -gt "$TITLE_WIDTH" ]; then
            short="''${title:0:$((TITLE_WIDTH - 1))}…"
          else
            short="$title"
          fi
          chars=''${#short}
          spaces=$((TITLE_WIDTH - chars))
          printf '%s%*s    %s\n' "$short" "$spaces" "" "$url"
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
          local args=(--dmenu -p "$prompt: " -l 12 "''${FUZZEL_STYLE[@]}")
          [ -n "$search" ] && args+=(--search="$search")
          "$FUZZEL" "''${args[@]}"
        }

        case "$mode" in
          bookmarks) selection=$(menu_bookmarks | run_fuzzel "bookmark" "") ;;
          edit)      selection=$(menu_open      | run_fuzzel "open"     "$QUTE_URL") ;;
          *)         selection=$(menu_open      | run_fuzzel "open"     "") ;;
        esac

        [ -z "$selection" ] && exit 0

        url=$(printf '%s' "$selection" | grep -oE 'https?://\S+' | tail -1)
        [ -z "$url" ] && url="$selection"
        [ -z "$url" ] && exit 0

        case "$mode" in
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
                      '--match-nth=1', '--with-nth=2', '--index',
                      '-p', 'tab: ', '-l', '12',
                    ],
                    input='\n'.join(lines),
                    capture_output=True,
                    text=True,
                )
                if proc.returncode != 0 or not proc.stdout.strip():
                    return None
                return int(proc.stdout.strip())


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
                tabs_info = [(e[1], e[0]) for e in entries]

                idx = pick_tab(lines)
                if idx is None:
                    sys.exit(0)

                _, tid = tabs_info[idx]
                with open(fifo, 'a') as f:
                    f.write(f'tab-focus {tid}\n')


            main()
          '';
    in
    {
      home.packages = lib.optionals useFuzzel [
        fuzzelOpen
        fuzzelTabs
      ];

      home.file = lib.optionalAttrs useFuzzel {
        ".local/share/qutebrowser/userscripts/qute-fuzzel-open".source =
          "${fuzzelOpen}/bin/qute-fuzzel-open";
        ".local/share/qutebrowser/userscripts/qute-fuzzel-tabs".source =
          "${fuzzelTabs}/bin/qute-fuzzel-tabs";
      };

      programs.qutebrowser = {
        enable = true;
        quickmarks = lib.listToAttrs (
          map (b: {
            name = b.name;
            value = b.url;
          }) config.browserBookmarks
        );
        searchEngines = {
          DEFAULT = "https://duckduckgo.com/?q={}";
          g = "https://www.google.com/search?q={}";
          ya = "https://yandex.ru/search/?text={}";
          yt = "https://www.youtube.com/results?search_query={}";
        };
        extraConfig = ''
          config.unbind("q")
          config.bind("<Alt-q>", "record-macro")
          config.bind("J", "tab-prev")
          config.bind("K", "tab-next")
          config.bind("d", "cmd-run-with-count 15 scroll down")
          config.bind("u", "cmd-run-with-count 15 scroll up")
          config.bind("x", "tab-close")
          config.bind("X", "undo")
          config.unbind("<Ctrl-w>")
          c.auto_save.session = True
          c.session.lazy_restore = True
          c.statusbar.show = "in-mode"
          c.tabs.padding = {"bottom": 5, "left": 16, "right": 16, "top": 5}
          c.statusbar.padding = {"bottom": 4, "left": 16, "right": 16, "top": 4}
          c.colors.webpage.preferred_color_scheme = "dark"
          c.colors.webpage.darkmode.enabled = True
          c.scrolling.smooth = True
          config.unbind("<Ctrl-d>")
          config.unbind("<Ctrl-u>")
          c.tabs.indicator.width = 4
          c.fonts.tabs.selected = "default_size default_family"
          c.content.javascript.clipboard = "access"
          c.content.autoplay = False
          config.bind(",m", "spawn mpv-mini {url}")
          config.bind(",M", "hint links spawn mpv-mini {hint-url}")
          config.bind(",a", "spawn umpv-mini {url}")
          config.bind(",A", "hint links spawn umpv-mini {hint-url}")
          config.bind(";A", "hint --rapid links spawn umpv-mini {hint-url}")
          c.hints.uppercase = True
          c.colors.tabs.selected.odd.bg = "#${config.lib.stylix.colors.base0D}"
          c.colors.tabs.selected.even.bg = "#${config.lib.stylix.colors.base0D}"
          c.colors.tabs.selected.odd.fg = "#${config.lib.stylix.colors.base00}"
          c.colors.tabs.selected.even.fg = "#${config.lib.stylix.colors.base00}"

          ${lib.optionalString useFuzzel ''
            config.bind("o", "spawn --userscript qute-fuzzel-open open")
            config.bind("O", "spawn --userscript qute-fuzzel-open tab")
            config.bind("go", "spawn --userscript qute-fuzzel-open open")
            config.bind("ge", "spawn --userscript qute-fuzzel-open edit")
            config.bind("b", "spawn --userscript qute-fuzzel-open bookmarks")
            config.bind("T", "spawn --userscript qute-fuzzel-tabs")
          ''}

          c.bindings.key_mappings.update({
              'й': 'q', 'ц': 'w', 'у': 'e', 'к': 'r', 'е': 't', 'н': 'y', 'г': 'u', 'ш': 'i', 'щ': 'o', 'з': 'p', 'х': '[', 'ъ': ']',
              'ф': 'a', 'ы': 's', 'в': 'd', 'а': 'f', 'п': 'g', 'р': 'h', 'о': 'j', 'л': 'k', 'д': 'l', 'ж': ';', 'э': "'",
              'я': 'z', 'ч': 'x', 'с': 'c', 'м': 'v', 'и': 'b', 'т': 'n', 'ь': 'm', 'б': ',', 'ю': '.',
              'Й': 'Q', 'Ц': 'W', 'У': 'E', 'К': 'R', 'Е': 'T', 'Н': 'Y', 'Г': 'U', 'Ш': 'I', 'Щ': 'O', 'З': 'P', 'Х': '{', 'Ъ': '}',
              'Ф': 'A', 'Ы': 'S', 'В': 'D', 'А': 'F', 'П': 'G', 'Р': 'H', 'О': 'J', 'Л': 'K', 'Д': 'L', 'Ж': ':', 'Э': '"',
              'Я': 'Z', 'Ч': 'X', 'С': 'C', 'М': 'V', 'И': 'B', 'Т': 'N', 'Ь': 'M', 'Б': '<', 'Ю': '>',
          })
        '';
      };
    };
}
