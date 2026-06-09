{
  flake.modules.homeManager.brave =
    {
      config,
      lib,
      pkgs-stable,
      ...
    }:
    let
      configDir = "${config.xdg.configHome}/BraveSoftware/Brave-Browser";
      profileDir = "${configDir}/Default";

      extensionJson = id: {
        name = "${configDir}/External Extensions/${id}.json";
        value.text = builtins.toJSON {
          external_update_url = "https://clients2.google.com/service/update2/crx";
        };
      };
    in
    {
      home.packages = [ pkgs-stable.brave ];

      home.file = builtins.listToAttrs (map extensionJson config.browserExtensions.chromiumIds);

      home.activation.braveBookmarks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p "${profileDir}"
        $DRY_RUN_CMD cp --no-preserve=all ${config.chromiumCommon.bookmarksFile} "${profileDir}/Bookmarks"
      '';
    };
}
