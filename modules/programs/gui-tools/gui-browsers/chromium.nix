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
        MARKER="$HOME/.local/state/vimium-hint-css-chromium"
        CURRENT="${config.vimiumCssFile}"
        VIMIUM_EXT_ID="dbepggeogbaibhgnhhndojpepiihcmeb"
        VIMIUM_BASE="${profileDir}/Extensions/$VIMIUM_EXT_ID"
        STORAGE="${profileDir}/Local Extension Settings/$VIMIUM_EXT_ID"
        if [ "$(cat "$MARKER" 2>/dev/null)" != "$CURRENT" ]; then
          if [ -d "$VIMIUM_BASE" ]; then
            VIMIUM_VERSION=$(ls "$VIMIUM_BASE" | sort -V | tail -1)
            SETTINGS_JS="$VIMIUM_BASE/$VIMIUM_VERSION/lib/settings.js"
            if [ -f "$SETTINGS_JS" ]; then
              $DRY_RUN_CMD ${pkgs.python3}/bin/python3 \
                ${config.patchVimiumScript} "$SETTINGS_JS" ${config.vimiumCssFile}
              $DRY_RUN_CMD rm -rf "$STORAGE"
              $DRY_RUN_CMD mkdir -p "$HOME/.local/state"
              $DRY_RUN_CMD sh -c "echo '$CURRENT' > '$MARKER'"
            fi
          fi
        fi
      '';
    };
}
