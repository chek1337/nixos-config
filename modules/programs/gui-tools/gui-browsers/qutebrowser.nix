{
  flake.modules.homeManager.qutebrowser =
    { ... }:
    {
      programs.qutebrowser = {
        enable = true;
        quickmarks = {
          vk = "https://vk.com";
          yt = "https://youtube.com";
          gmap = "https://www.google.com/maps";
          yamap = "https://yandex.com/maps/65/novosibirsk/";
          dmap = "https://2gis.ru/novosibirsk";
          gtrans = "https://translate.google.com";
          yatrans = "https://translate.yandex.com";
          grok = "https://grok.com";
          deepseek = "https://chat.deepseek.com";
          gpt = "https://chatgpt.com";
          zai = "https://z.ai";
          claude = "https://claude.ai";
          gh = "https://github.com";
          snix = "https://search.nixos.org/packages";
        };
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
        '';
      };
    };
}
