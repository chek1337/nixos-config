{ inputs, ... }:
{
  flake.modules.homeManager.yandex-browser =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      configDir = "${config.xdg.configHome}/yandex-browser";
      profileDir = "${configDir}/Default";

      extensionJson = id: {
        name = "${configDir}/External Extensions/${id}.json";
        value.text = builtins.toJSON {
          external_update_url = "https://clients2.google.com/service/update2/crx";
        };
      };
    in
    {
      home.packages = [
        (inputs.yandex-browser.packages.x86_64-linux.yandex-browser-beta.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            rm -f $out/share/icons/hicolor/icon-theme.cache
          '';
        }))
      ];

      home.file = builtins.listToAttrs (map extensionJson config.browserExtensions.chromiumIds);

      home.activation.yandexBrowserBookmarks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p "${profileDir}"
        $DRY_RUN_CMD cp --no-preserve=all ${config.chromiumCommon.bookmarksFile} "${profileDir}/Bookmarks"
      '';

      home.activation.vimiumCssYandex = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        MARKER="$HOME/.local/state/vimium-hint-css-yandex"
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
