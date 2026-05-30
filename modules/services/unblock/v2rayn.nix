{ inputs, ... }:
{
  flake.modules.nixos.v2rayn =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      v2rayN-upstream = pkgs.stdenv.mkDerivation rec {
        pname = "v2rayN";
        version = "7.22.3";

        src = pkgs.fetchurl {
          url = "https://github.com/2dust/v2rayN/releases/download/${version}/v2rayN-linux-64.zip";
          hash = "sha256-QFyL+kR3S50rj77I3CY/xNLDqe82lptcSHOiqO5JRcc=";
        };

        sourceRoot = "v2rayN-linux-64";

        nativeBuildInputs = with pkgs; [
          unzip
          autoPatchelfHook
          copyDesktopItems
          makeWrapper
        ];

        buildInputs = with pkgs; [
          zlib
          fontconfig
          icu
          openssl
          krb5
          lttng-ust_2_12
          (lib.getLib stdenv.cc.cc)
          libx11
          libxrandr
          libxi
          libice
          libsm
          libxcursor
          libxext
        ];

        # bin/xray/sing-box/mihomo/srss и geo-данные нам не нужны: HM-часть этого
        # модуля кладёт свои xray/sing-box/geoip.dat/geosite.dat из nixpkgs в
        # ~/.local/share/v2rayN/bin/. Удаление избавляет autoPatchelfHook от
        # лишних Go-бинарей с непокрытыми зависимостями.
        autoPatchelfIgnoreMissingDeps = true;

        desktopItems = [
          (pkgs.makeDesktopItem {
            name = "v2rayn";
            exec = "v2rayN";
            icon = "v2rayn";
            genericName = "v2rayN";
            desktopName = "v2rayN";
            categories = [ "Network" ];
            terminal = false;
            comment = "GUI client supporting Xray core and sing-box-core";
          })
        ];

        installPhase = ''
          runHook preInstall

          mkdir -p $out/share/v2rayN
          cp -a . $out/share/v2rayN/
          rm -rf $out/share/v2rayN/bin

          chmod +x $out/share/v2rayN/v2rayN $out/share/v2rayN/AmazTool

          install -D --mode 0644 v2rayN.png \
            $out/share/icons/hicolor/256x256/apps/v2rayn.png

          mkdir -p $out/bin
          # .NET грузит ICU через dlopen, поэтому autoPatchelfHook её не находит.
          # Прокидываем libicu (и другие dlopen-зависимости) через LD_LIBRARY_PATH.
          makeWrapper $out/share/v2rayN/v2rayN $out/bin/v2rayN \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

          runHook postInstall
        '';

        meta = with lib; {
          description = "GUI client supporting Xray core and sing-box-core (upstream binary)";
          homepage = "https://github.com/2dust/v2rayN";
          license = licenses.gpl3Plus;
          platforms = [ "x86_64-linux" ];
          mainProgram = "v2rayN";
        };
      };
    in
    {
      sops.secrets."vless-chumakov" = {
        sopsFile = inputs.self + "/secrets/secrets.yaml";
        key = "vless-chumakov";
        owner = config.settings.username;
      };

      environment.systemPackages = [ v2rayN-upstream ];
    };

  flake.modules.homeManager.v2rayn =
    { pkgs, ... }:
    {
      xdg.dataFile = {
        "v2rayN/bin/xray/xray".source = "${pkgs.xray}/bin/xray";
        "v2rayN/bin/sing_box/sing-box".source = "${pkgs.sing-box}/bin/sing-box";
        "v2rayN/bin/geoip.dat".source = "${pkgs.v2ray-geoip}/share/v2ray/geoip.dat";
        "v2rayN/bin/geosite.dat".source = "${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat";
      };

      programs.zsh.shellAliases = {
        vless-show = "cat /run/secrets/vless-chumakov";
        vless-copy = "cat /run/secrets/vless-chumakov | wl-copy";
      };
    };
}
