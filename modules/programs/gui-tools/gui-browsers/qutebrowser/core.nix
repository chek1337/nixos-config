{
  flake.modules.homeManager.qutebrowser-core =
    {
      lib,
      config,
      ...
    }:
    {
      programs.qutebrowser = {
        quickmarks = lib.listToAttrs (
          map (b: {
            name = b.name;
            value = b.url;
          }) config.browserBookmarks
        );
        searchEngines =
          let
            defaultEngine = lib.findFirst (e: e.default) null (lib.attrValues config.browserSearchEngines);
            named = lib.mapAttrs (_: e: e.url) config.browserSearchEngines;
          in
          named // lib.optionalAttrs (defaultEngine != null) { DEFAULT = defaultEngine.url; };
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
