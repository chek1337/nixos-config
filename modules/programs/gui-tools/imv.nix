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

    };
}
