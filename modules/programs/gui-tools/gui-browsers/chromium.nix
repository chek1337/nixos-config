{ ... }:
{
  flake.modules.homeManager.chromium =
    {
      config,
      lib,
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
    };
}
