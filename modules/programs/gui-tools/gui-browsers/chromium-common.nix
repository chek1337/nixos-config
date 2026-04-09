{
  flake.modules.homeManager.chromium-common =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.chromiumCommon.bookmarksFile = lib.mkOption {
        type = lib.types.path;
        readOnly = true;
        description = "Pre-generated Bookmarks JSON file derived from browserBookmarks";
      };

      config.chromiumCommon.bookmarksFile = pkgs.writeText "chromium-bookmarks" (
        builtins.toJSON {
          checksum = "";
          roots = {
            bookmark_bar = {
              children = lib.imap0 (i: b: {
                date_added = "13285932715429780";
                date_last_used = "0";
                guid = "bookmark-${toString i}-0000-0000-0000-000000000000";
                id = toString (i + 4);
                name = b.name;
                source = "unknown";
                type = "url";
                url = b.url;
              }) config.browserBookmarks;
              date_added = "13285932715429780";
              date_last_used = "0";
              date_modified = "13285932715429780";
              guid = "0bc5d13f-2cba-5d74-951f-3f233fe6c908";
              id = "1";
              name = "Bookmarks bar";
              source = "unknown";
              type = "folder";
            };
            other = {
              children = [ ];
              date_added = "13285932715429780";
              date_last_used = "0";
              date_modified = "0";
              guid = "82b081ec-3dd3-529c-8475-ab6c344590dd";
              id = "2";
              name = "Other bookmarks";
              source = "unknown";
              type = "folder";
            };
            synced = {
              children = [ ];
              date_added = "13285932715429780";
              date_last_used = "0";
              date_modified = "0";
              guid = "4cf2e351-0e85-532b-bb37-df045d8f8d0f";
              id = "3";
              name = "Mobile bookmarks";
              source = "unknown";
              type = "folder";
            };
          };
          version = 1;
        }
      );
    };
}
