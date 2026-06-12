{
  flake.modules.homeManager.imv =
    { pkgs, ... }:
    let
      imvSvg = pkgs.writeShellScriptBin "imv-svg" ''
        if [ "$#" -eq 1 ]; then
          exec ${pkgs.imv}/bin/imv -b ffffff -n "$1" "$(${pkgs.coreutils}/bin/dirname "$1")"
        fi

        exec ${pkgs.imv}/bin/imv -b ffffff "$@"
      '';
    in
    {
      home.packages = [
        pkgs.imv
        imvSvg
      ];

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

      xdg.desktopEntries.imv-svg = {
        name = "imv SVG";
        exec = "imv-svg %f";
        mimeType = [
          "image/svg+xml"
          "image/svg+xml-compressed"
        ];
        noDisplay = true;
      };

    };
}
