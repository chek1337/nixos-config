{ self, pkgs }:
let
  xpi = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/thunderbird/main/themes/mocha/mocha-lavender.xpi";
    hash = "sha256-ryekzqL/alt/08Yb2zVS4qOhJfBPV2gA4qA7tQh8+FY=";
  };
in
{
  image = self + "/assets/catppuccin-mocha.png";
  icons = {
    package = pkgs.catppuccin-papirus-folders;
    dark = "Papirus-Dark";
    light = "Papirus";
  };
  thunderbird =
    pkgs.runCommandLocal "catppuccin-mocha-lavender-thunderbird"
      {
        nativeBuildInputs = with pkgs; [
          jq
          unzip
        ];
      }
      ''
        extId=$(unzip -qc ${xpi} manifest.json | jq -r '(.applications.gecko.id // .browser_specific_settings.gecko.id)')
        install -Dv ${xpi} $out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/$extId.xpi
      '';
}
