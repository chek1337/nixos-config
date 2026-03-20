{
  flake.modules.homeManager.mpv =
    { ... }:
    {
      programs.mpv = {
        enable = true;
        bindings = {
          "Shift+LEFT" = "seek -0.1 exact";
          "Shift+RIGHT" = "seek 0.1 exact";
        };
      };

      programs.zsh.shellAliases.mpva = "mpv --no-video";

      xdg.mimeApps.defaultApplications = {
        "audio/*" = "mpv.desktop";
        "video/*" = "mpv.desktop";
      };
    };
}
