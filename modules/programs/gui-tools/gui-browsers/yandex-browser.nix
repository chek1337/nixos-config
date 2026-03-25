{ inputs, ... }:
{
  flake.modules.homeManager.yandex-browser =
    { ... }:
    {
      home.packages = [
        (inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            rm -f $out/share/icons/hicolor/icon-theme.cache
          '';
        }))
      ];
    };
}
