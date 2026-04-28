{ self, pkgs-unstable }:
let
  xpi = pkgs-unstable.fetchurl {
    url = "https://addons.thunderbird.net/thunderbird/downloads/file/1044695/gruvbox_dark_thunderbird-1.12-tb.xpi";
    hash = "sha256-/3f1tttzVtntAkmNhHxSAXoBwrhYwu2sqGfjoM0i7JE=";
  };
in
{
  image = self + "/assets/gruvbox-dark-hard.png";
  icons = {
    package = pkgs-unstable.gruvbox-plus-icons;
    dark = "Gruvbox-Plus-Dark";
    light = "Gruvbox-Plus-Light";
  };
  thunderbird =
    pkgs-unstable.runCommandLocal "gruvbox-dark-thunderbird"
      {
        nativeBuildInputs = with pkgs-unstable; [
          jq
          unzip
        ];
      }
      ''
        extId=$(unzip -qc ${xpi} manifest.json | jq -r '(.applications.gecko.id // .browser_specific_settings.gecko.id)')
        install -Dv ${xpi} $out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/$extId.xpi
      '';
}
