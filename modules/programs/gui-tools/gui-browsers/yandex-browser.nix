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
        (inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable.overrideAttrs (old: {
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
    };
}
