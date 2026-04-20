{ ... }:
{
  flake.modules.homeManager.browser-extensions =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      cssFile = pkgs.writeText "vimium-hint.css" config.vimiumHintCss;

      patchScript = pkgs.writeText "patch-vimium-settings.py" ''
        import re, sys

        settings_file, css_file = sys.argv[1], sys.argv[2]
        css = open(css_file).read().strip()

        with open(settings_file) as f:
            content = f.read()

        patched = re.sub(
            r"(userDefinedLinkHintCss: `)\\\n.*?\\\n(`)",
            lambda m: m.group(1) + "\\\n" + css + "\\\n" + m.group(2),
            content,
            flags=re.DOTALL
        )

        with open(settings_file, "w") as f:
            f.write(patched)
      '';

      # NOTE: патчинг XPI не работает надёжно в некоторых браузерах — отключено.
      # Используй `vimium-css` для получения CSS и ручной вставки в настройки Vimium.
      # patchedVimiumFf = pkgs.firefoxAddons.vimium-ff.overrideAttrs (old: {
      #   nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      #     pkgs.unzip
      #     pkgs.zip
      #   ];
      #   buildCommand = (old.buildCommand or "") + ''
      #     XPI=$(find $out -name "*.xpi" | head -1)
      #     TMPDIR=$(mktemp -d)
      #     unzip -q "$XPI" -d "$TMPDIR"
      #     ${pkgs.python3}/bin/python3 ${patchScript} "$TMPDIR/lib/settings.js" ${cssFile}
      #     rm "$XPI"
      #     (cd "$TMPDIR" && zip -qr "$XPI" .)
      #     rm -rf "$TMPDIR"
      #   '';
      # });

      vimiumCssScript = pkgs.writeShellScriptBin "vimium-css" ''
        echo "Вставь этот CSS в настройки Vimium (CSS for link hints):"
        echo ""
        cat ${cssFile}
      '';
    in
    {
      options = {
        vimiumHintCss = lib.mkOption {
          type = lib.types.str;
          description = "Custom CSS for Vimium hint markers";
        };
        vimiumCssFile = lib.mkOption {
          type = lib.types.path;
          readOnly = true;
          description = "Vimium hint CSS written to nix store for use in activation scripts";
        };
        patchVimiumScript = lib.mkOption {
          type = lib.types.path;
          readOnly = true;
          description = "Python script to patch Vimium settings.js with custom hint CSS";
        };
        browserExtensions = {
          chromiumIds = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Chrome Web Store extension IDs for Chromium-based browsers";
          };
          firefoxPackages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
            description = "Firefox addon packages for Firefox-based browsers";
          };
        };
      };

      config = {
        home.packages = [ vimiumCssScript ];

        vimiumHintCss = lib.mkDefault ''
          div > .vimiumHintMarker {
            background: #${config.lib.stylix.colors.base01} !important;
            border: none !important;
            outline: none !important;
            box-shadow: none !important;
            padding: 2px 5px !important;
            border-radius: 3px !important;
          }

          div > .vimiumHintMarker span {
            color: #${config.lib.stylix.colors.base05} !important;
            font-weight: bold !important;
            font-size: 13px !important;
          }

          div > .vimiumHintMarker > .matchingCharacter {
            color: #${config.lib.stylix.colors.base0B} !important;
          }
        '';

        vimiumCssFile = cssFile;
        patchVimiumScript = patchScript;

        browserExtensions = {
          chromiumIds = [
            "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
            "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
            "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
            "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
            "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
            "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
            "edibdbjcniadpccecjdfdjjppcpchdlm" # I Still Don't Care About Cookies
          ];
          firefoxPackages = with pkgs.firefoxAddons; [
            ublock-origin
            sponsorblock
            darkreader
            vimium-ff
            privacy-badger17
            decentraleyes
            istilldontcareaboutcookies
          ];
        };
      };
    };
}
