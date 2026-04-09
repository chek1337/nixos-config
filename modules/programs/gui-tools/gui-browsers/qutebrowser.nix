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

      fuzzelOpen = pkgs.writeShellScriptBin "qute-fuzzel-open" ''
        mode="''${1:-open}"

        create_menu() {
          [ -n "$QUTE_URL" ] && printf '%s\n' "$QUTE_URL"

          if [ -f "$QUTE_CONFIG_DIR/quickmarks" ]; then
            while read -r line; do
              name="''${line%% *}"
              url="''${line#* }"
              printf '[%s] %s\n' "$name" "$url"
            done < "$QUTE_CONFIG_DIR/quickmarks"
          fi

          if [ -f "$QUTE_CONFIG_DIR/bookmarks/urls" ]; then
            cat "$QUTE_CONFIG_DIR/bookmarks/urls"
          fi

          ${pkgs.sqlite}/bin/sqlite3 -separator '  ' "$QUTE_DATA_DIR/history.sqlite" \
            'SELECT COALESCE(title, url), url FROM CompletionHistory ORDER BY last_atime DESC LIMIT 500'
        }

        create_bookmarks_menu() {
          if [ -f "$QUTE_CONFIG_DIR/quickmarks" ]; then
            while read -r line; do
              name="''${line%% *}"
              url="''${line#* }"
              printf '[%s] %s\n' "$name" "$url"
            done < "$QUTE_CONFIG_DIR/quickmarks"
          fi

          if [ -f "$QUTE_CONFIG_DIR/bookmarks/urls" ]; then
            cat "$QUTE_CONFIG_DIR/bookmarks/urls"
          fi
        }

        fuzzel_style="
          --background-color=1e1e2eff
          --text-color=cdd6f4ff
          --input-color=cdd6f4ff
          --prompt-color=6c7086ff
          --match-color=89b4faff
          --selection-color=313244ff
          --selection-text-color=cdd6f4ff
          --selection-match-color=89b4faff
          --border-color=45475aff
          --border-width=2
          --border-radius=6
          -w 100
        "

        case "$mode" in
          bookmarks) menu=create_bookmarks_menu; prompt="bookmark:" ;;
          edit)      menu=create_menu;           prompt="open:" ;;
          *)         menu=create_menu;           prompt="open:" ;;
        esac

        # shellcheck disable=SC2086
        fuzzel_args="--dmenu -p $prompt -l 8 $fuzzel_style"
        if [ "$mode" = "edit" ] && [ -n "$QUTE_URL" ]; then
          fuzzel_args="$fuzzel_args --search=$QUTE_URL"
        fi

        # shellcheck disable=SC2086
        selection=$($menu | ${pkgs.fuzzel}/bin/fuzzel $fuzzel_args)
        [ -z "$selection" ] && exit 0

        url=$(printf '%s' "$selection" | grep -oE 'https?://\S+' | tail -1)
        [ -z "$url" ] && url="$selection"
        [ -z "$url" ] && exit 0

        case "$mode" in
          open|edit|bookmarks) printf 'open %s\n' "$url" >> "$QUTE_FIFO" ;;
          tab)                 printf 'open -t %s\n' "$url" >> "$QUTE_FIFO" ;;
          window)              printf 'open -w %s\n' "$url" >> "$QUTE_FIFO" ;;
          private)             printf 'open -p %s\n' "$url" >> "$QUTE_FIFO" ;;
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

            FUZZEL = "${pkgs.fuzzel}/bin/fuzzel"

            data_dir = os.environ.get('QUTE_DATA_DIR') or ""
            fifo = os.environ.get('QUTE_FIFO') or ""
            session_file = os.path.join(data_dir, 'sessions', '_autosave.yml')

            if not os.path.exists(session_file):
                sys.exit(1)

            with open(session_file) as f:
                data = yaml.safe_load(f)

            lines = []
            tabs_info = []
            for wid, window in enumerate(data.get('windows', [])):
                for tid, tab in enumerate(window.get('tabs', [])):
                    history = tab.get('history', [])
                    if not history:
                        continue
                    last = history[-1]
                    title = last.get('title') or ""
                    url = last.get('url') or ""
                    active = '* ' if tab.get('active') else '  '
                    line = f'[W{wid+1} T{tid+1}]{active}{title}  {url}'
                    lines.append(line)
                    tabs_info.append((wid + 1, tid + 1))

            if not lines:
                sys.exit(1)

            proc = subprocess.run(
                [FUZZEL, '--dmenu', '-p', 'tab: ', '-l', '20'],
                input='\n'.join(lines),
                capture_output=True,
                text=True,
            )

            if proc.returncode != 0 or not proc.stdout.strip():
                sys.exit(0)

            selection = proc.stdout.strip()
            for i, line in enumerate(lines):
                if line == selection:
                    _, tid = tabs_info[i]
                    with open(fifo, 'a') as f:
                        f.write(f'tab-focus {tid}\n')
                    break
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
          config.unbind("d")
          config.bind("dd", "tab-close")
          config.unbind("<Ctrl-w>")
          c.auto_save.session = True
          c.session.lazy_restore = True
          c.statusbar.show = "in-mode"
          c.tabs.padding = {"bottom": 5, "left": 16, "right": 16, "top": 5}
          c.statusbar.padding = {"bottom": 4, "left": 16, "right": 16, "top": 4}
          c.colors.webpage.preferred_color_scheme = "dark"
          c.colors.webpage.darkmode.enabled = True
          c.scrolling.smooth = True
          config.bind("<Ctrl-d>", "cmd-run-with-count 15 scroll down")
          config.bind("<Ctrl-u>", "cmd-run-with-count 15 scroll up")
          c.tabs.indicator.width = 4
          c.fonts.tabs.selected = "bold default_size default_family"
          c.content.javascript.clipboard = "access"
          c.content.autoplay = False
          config.bind(",m", "spawn mpv-mini {url}")
          config.bind(",M", "hint links spawn mpv-mini {hint-url}")
          config.bind(",a", "spawn umpv-mini {url}")
          config.bind(",A", "hint links spawn umpv-mini {hint-url}")
          config.bind(";A", "hint --rapid links spawn umpv-mini {hint-url}")
          c.hints.uppercase = True

          ${lib.optionalString useFuzzel ''
            config.bind("o", "spawn --userscript qute-fuzzel-open open")
            config.bind("O", "spawn --userscript qute-fuzzel-open tab")
            config.bind("go", "spawn --userscript qute-fuzzel-open open")
            config.bind("e", "spawn --userscript qute-fuzzel-open edit")
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
