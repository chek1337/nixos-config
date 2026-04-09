{ ... }:
{
  flake.modules.homeManager.chromium =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      profileDir = "${config.xdg.configHome}/chromium/Default";
    in
    {
      programs.chromium = {
        enable = true;
        extensions = map (id: { inherit id; }) config.browserExtensions.chromiumIds;
      };

      home.activation.chromiumBookmarks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p "${profileDir}"
        $DRY_RUN_CMD cp --no-preserve=all ${config.chromiumCommon.bookmarksFile} "${profileDir}/Bookmarks"
      '';

      home.activation.vimiumCssChromium = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        VIMIUM_BASE="${profileDir}/Extensions/dbepggeogbaibhgnhhndojpepiihcmeb"
        if [ -d "$VIMIUM_BASE" ]; then
          VIMIUM_VERSION=$(ls "$VIMIUM_BASE" | sort -V | tail -1)
          SETTINGS_JS="$VIMIUM_BASE/$VIMIUM_VERSION/lib/settings.js"
          if [ -f "$SETTINGS_JS" ]; then
            $DRY_RUN_CMD ${pkgs.python3}/bin/python3 \
              ${config.patchVimiumScript} "$SETTINGS_JS" ${config.vimiumCssFile}
          fi
        fi
      '';
    };
}
