{
  flake.modules.homeManager.mpv =
    { ... }:
    {
      programs.mpv.enable = true;

      xdg.mimeApps.defaultApplications = {
        "audio/*" = "mpv.desktop";
        "video/*" = "mpv.desktop";
      };
    };
}
