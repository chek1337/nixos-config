{
  flake.modules.homeManager.qutebrowser =
    { ... }:
    {
      programs.qutebrowser = {
        enable = true;
        quickmarks = {
          vk = "https://vk.com";
          yt = "https://youtube.com";
          maps = "https://maps.google.com";
          translate = "https://translate.google.com";
          grok = "https://grok.x.ai";
          deepseek = "https://chat.deepseek.com";
          gpt = "https://chatgpt.com";
          zai = "https://z.ai";
        };
        extraConfig = ''
          config.bind("q", "mode-leave")
          config.bind("<Alt-q>", "record-macro")
          config.bind("J", "tab-prev")
          config.bind("K", "tab-next")

          c.statusbar.show = "in-mode"
          c.tabs.padding = {"bottom": 5, "left": 16, "right": 16, "top": 5}
          c.statusbar.padding = {"bottom": 4, "left": 16, "right": 16, "top": 4}
          c.colors.webpage.preferred_color_scheme = "dark"
          c.colors.webpage.darkmode.enabled = True
          c.scrolling.smooth = True
          config.bind("<Ctrl-d>", "cmd-run-with-count 15 scroll down")
          config.bind("<Ctrl-u>", "cmd-run-with-count 15 scroll up")
        '';
      };
    };
}
