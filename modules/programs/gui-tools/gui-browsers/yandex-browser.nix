{ inputs, ... }:
{
  flake.modules.homeManager.yandex-browser =
    { config, ... }:
    let
      configDir = "${config.xdg.configHome}/yandex-browser";

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
    };
}
