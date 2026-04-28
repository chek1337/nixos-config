{ self, pkgs-unstable }:
let
  xpi = pkgs-unstable.fetchurl {
    url = "https://addons.thunderbird.net/thunderbird/downloads/file/1019076/nord_dark-1.0-tb.xpi";
    hash = "sha256-z782Ywv0D8Lipj2mLzXtgXyRD3aEONDNcyLSP4dXH4M=";
  };
in
{
  image = self + "/assets/nord2.png";
  icons = {
    package = pkgs-unstable.nordzy-icon-theme;
    dark = "Nordzy-dark";
    light = "Nordzy";
  };
  thunderbird =
    pkgs-unstable.runCommandLocal "nord-dark-thunderbird"
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
