{
  flake.modules.homeManager.nautilus =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ nautilus ];

      xdg.mimeApps.defaultApplications = {
        "inode/directory" = "org.gnome.Nautilus.desktop";
        "audio/*" = "mpv.desktop";
        "video/*" = "mpv.desktop";
        "image/*" = "imv.desktop";
      };
    };
}
