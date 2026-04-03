{
  flake.modules.homeManager.imv =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.imv ];

      xdg.desktopEntries.imv-dir = {
        name = "imv-dir";
        exec = "imv-dir %f";
        mimeType = [
          "image/png"
          "image/jpeg"
          "image/gif"
          "image/webp"
          "image/bmp"
          "image/tiff"
        ];
        noDisplay = true;
      };

      xdg.mimeApps.defaultApplications = {
        "image/png" = "imv-dir.desktop";
        "image/jpeg" = "imv-dir.desktop";
        "image/gif" = "imv-dir.desktop";
        "image/webp" = "imv-dir.desktop";
        "image/bmp" = "imv-dir.desktop";
        "image/tiff" = "imv-dir.desktop";
      };
    };
}
