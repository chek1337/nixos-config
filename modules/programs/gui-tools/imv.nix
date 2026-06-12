{
  flake.modules.homeManager.imv =
    { pkgs, ... }:
    let
      imvWheelZoomScale = "0.1";
      imv = pkgs.imv.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (pkgs.writeText "imv-wheel-zoom-scale.patch" ''
            diff --git a/src/imv.c b/src/imv.c
            --- a/src/imv.c
            +++ b/src/imv.c
            @@ -472,2 +472,2 @@
            -        imv_viewport_zoom(imv->view, imv->current_image, IMV_ZOOM_MOUSE,
            -            x, y, -e->data.mouse_scroll.dy);
            +        imv_viewport_zoom(imv->view, imv->current_image, IMV_ZOOM_MOUSE,
            +            x, y, -e->data.mouse_scroll.dy * ${imvWheelZoomScale});
            diff --git a/src/viewport.c b/src/viewport.c
            --- a/src/viewport.c
            +++ b/src/viewport.c
            @@ -186,1 +186,1 @@
            -                       enum imv_zoom_source src, int mouse_x, int mouse_y, int amount)
            +                       enum imv_zoom_source src, int mouse_x, int mouse_y, double amount)
            diff --git a/src/viewport.h b/src/viewport.h
            --- a/src/viewport.h
            +++ b/src/viewport.h
            @@ -61,1 +61,1 @@
            -                       enum imv_zoom_source, int mouse_x, int mouse_y, int amount);
            +                       enum imv_zoom_source, int mouse_x, int mouse_y, double amount);
          '')
        ];
      });
      imvSvg = pkgs.writeShellScriptBin "imv-svg" ''
        if [ "$#" -eq 1 ]; then
          exec ${imv}/bin/imv -b ffffff -n "$1" "$(${pkgs.coreutils}/bin/dirname "$1")"
        fi

        exec ${imv}/bin/imv -b ffffff "$@"
      '';
    in
    {
      home.packages = [
        imv
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
