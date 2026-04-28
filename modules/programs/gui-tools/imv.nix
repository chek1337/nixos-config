{
  flake.modules.homeManager.imv =
    { pkgs-stable, ... }:
    {
      home.packages = [ pkgs-stable.imv ];

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

    };
}
