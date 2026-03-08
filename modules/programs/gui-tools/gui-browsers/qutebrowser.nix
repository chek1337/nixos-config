{
  flake.modules.homeManager.qutebrowser =
    { ... }:
    {
      programs.qutebrowser = {
        enable = true;
        extraConfig = ''
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
