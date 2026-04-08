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

      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
        "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
        "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
        "edibdbjcniadpccecjdfdjjppcpchdlm" # I Still Don't Care About Cookies
      ];

      bookmarksFile = pkgs.writeText "yandex-browser-bookmarks" (
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
    in
    {
      home.packages = [
        (inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            rm -f $out/share/icons/hicolor/icon-theme.cache
          '';
        }))
      ];

      home.file = builtins.listToAttrs (map extensionJson extensions);

      home.activation.yandexBrowserBookmarks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p "${profileDir}"
        $DRY_RUN_CMD cp --no-preserve=all ${bookmarksFile} "${profileDir}/Bookmarks"
      '';
    };
}
