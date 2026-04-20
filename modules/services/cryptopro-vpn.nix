# Модуль для корпоративного VPN через CryptoPro CSP + NGate.
#
# Как это работает:
#   CryptoPro и NGate — проприетарное ПО с hardcoded путями в /opt/cprocsp/.
#   На NixOS это не работает напрямую, поэтому используется FHS-окружение
#   (buildFHSEnv), которое эмулирует стандартную файловую структуру Linux.
#   Деривации распаковывают .deb/.tgz пакеты, а FHS-обёртка монтирует их
#   по ожидаемым путям. Сверху — скрипты-обёртки для удобного запуска.
#
# Установка из локальных файлов:
#   1. Скачать архив CryptoPro CSP (linux-amd64_deb.tgz) и положить в:
#        packages/cryptopro/linux-amd64_deb.tgz
#
#   2. Скачать установщик NGate и положить в:
#        packages/cryptopro/ngate-client.deb
#      (или .run/.bin — модуль пробует разные форматы)
#
#   3. Задеплоить конфигурацию: just sw laptop-asus
#
#   4. Задать лицензию CryptoPro CSP:
#        cryptopro-cli cpconfig -license -set <ключ-лицензии>
#
#   5. Положить сертификаты в ~/.config/cryptopro/certs/:
#        - CryproPro_GOST_Root_CA.cer
#        - CryptoPro_TLS_CA.cer
#      Затем запустить: cryptopro-import-certs
#      (либо пересобрать HM — activation сделает это автоматически)
#
#   6. Запустить ngate, указать адрес: https://global.gw.yadro.com
#      Ввести доменную учётку (без @yadro.com) и пароль.
#
# Доступные команды после установки:
#   - ngate              — запуск GUI клиента NGate
#   - cryptopro-cli ...  — запуск любой CLI утилиты CryptoPro (certmgr, cpconfig и т.д.)
#   - cryptopro-import-certs — импорт сертификатов из ~/.config/cryptopro/certs/
#   - cryptopro          — вход в FHS-окружение (bash) для ручной отладки
#
# Альтернатива: если нужна установка через fetchurl (например для CI),
#   раскомментируйте блок ниже и закомментируйте src = ./... строки.

{ inputs, ... }:
{
  flake.modules.nixos.cryptopro-vpn =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      username = config.settings.username;

      # CryptoPro CSP — распаковка .deb пакетов из архива
      cryptopro-csp = pkgs.stdenv.mkDerivation {
        pname = "cryptopro-csp";
        version = "5.0";

        # Локальный файл — положите архив в packages/cryptopro/
        src = inputs.self + "/packages/cryptopro/linux-amd64_deb.tgz";

        # --- Вариант с fetchurl (раскомментировать при необходимости): ---
        # src = pkgs.fetchurl {
        #   url = "https://example.com/linux-amd64_deb.tgz";
        #   hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        # };

        nativeBuildInputs = with pkgs; [
          dpkg
          autoPatchelfHook
        ];

        buildInputs = with pkgs; [
          stdenv.cc.cc.lib
          openssl
          zlib
          pcsclite
          lsb-release
        ];

        unpackPhase = ''
          mkdir -p source
          tar -xzf $src -C source
        '';

        installPhase = ''
          mkdir -p $out/opt/cprocsp $out/etc $out/lib

          # Распаковка всех .deb пакетов
          for deb in source/*.deb; do
            dpkg-deb -x "$deb" $out || true
          done

          # CryptoPro ставит всё в /opt/cprocsp
          if [ -d "$out/opt/cprocsp" ]; then
            echo "CryptoPro CSP unpacked successfully"
          fi
        '';

        dontFixup = true;
      };

      # CryptoPro NGate Client
      cryptopro-ngate = pkgs.stdenv.mkDerivation {
        pname = "cryptopro-ngate";
        version = "1.0.30";

        # Локальный файл — положите установщик в packages/cryptopro/
        src = inputs.self + "/packages/cryptopro/ngate-client.deb";

        # --- Вариант с fetchurl (раскомментировать при необходимости): ---
        # src = pkgs.fetchurl {
        #   url = "https://example.com/ngate-client-installer-lin-offline-1.0.30-128-g5ebbbb2-x64";
        #   hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        #   executable = true;
        # };

        nativeBuildInputs = with pkgs; [
          dpkg
          autoPatchelfHook
        ];

        buildInputs = with pkgs; [
          stdenv.cc.cc.lib
          openssl
          zlib
          gtk3
          glib
          xorg.libX11
          xorg.libXext
          xorg.libXrender
          cairo
          pango
          gdk-pixbuf
          atk
        ];

        dontUnpack = true;

        installPhase = ''
          mkdir -p $out
          # Пробуем как .deb, если не получится — как self-extracting archive
          if dpkg-deb -x $src $out 2>/dev/null; then
            echo "Extracted as .deb"
          else
            # Self-extracting binary: пропускаем shell-скрипт header, извлекаем payload
            offset=$(grep -abon 'PAYLOAD_START' $src | tail -1 | cut -d: -f1 || echo "")
            if [ -n "$offset" ]; then
              tail -c +$((offset + 14)) $src | tar -xz -C $out
            else
              # Fallback: запуск с --extract если поддерживается
              cp $src installer
              chmod +x installer
              ./installer --noexec --target $out || ./installer --extract-only --target $out || {
                echo "WARNING: Could not extract NGate installer automatically."
                echo "Place extracted files manually in the store path."
                mkdir -p $out/opt/ngate
              }
            fi
          fi
        '';

        dontFixup = true;
      };

      # FHS-окружение, в котором CryptoPro и NGate работают как на обычном Linux
      cryptopro-fhs = pkgs.buildFHSEnv {
        name = "cryptopro";
        targetPkgs =
          p: with p; [
            # Системные зависимости
            openssl
            zlib
            pcsclite
            lsb-release
            coreutils
            bash
            # GUI зависимости для NGate
            gtk3
            glib
            xorg.libX11
            xorg.libXext
            xorg.libXrender
            cairo
            pango
            gdk-pixbuf
            atk
            dbus
            fontconfig
            freetype
            libGL
          ];
        extraBuildCommands = ''
          # Монтируем CryptoPro CSP в /opt/cprocsp
          mkdir -p etc/opt usr/lib
          if [ -d "${cryptopro-csp}/opt/cprocsp" ]; then
            ln -sf ${cryptopro-csp}/opt/cprocsp opt/cprocsp
          fi
          if [ -d "${cryptopro-csp}/etc/opt" ]; then
            cp -r ${cryptopro-csp}/etc/opt/* etc/opt/ || true
          fi

          # NGate
          if [ -d "${cryptopro-ngate}/opt" ]; then
            for d in ${cryptopro-ngate}/opt/*; do
              ln -sf "$d" opt/$(basename "$d")
            done
          fi
        '';
        runScript = "bash";
      };

      # Обёртка для NGate GUI
      ngate-wrapped = pkgs.writeShellScriptBin "ngate" ''
        exec ${cryptopro-fhs}/bin/cryptopro -c "
          export PATH=/opt/cprocsp/bin/amd64:/opt/cprocsp/sbin/amd64:\$PATH
          export LD_LIBRARY_PATH=/opt/cprocsp/lib/amd64:\$LD_LIBRARY_PATH
          # Запуск NGate клиента
          if [ -x /opt/ngate/ngate-client ]; then
            exec /opt/ngate/ngate-client \"\$@\"
          elif [ -x /opt/cprocsp/bin/amd64/ngate ]; then
            exec /opt/cprocsp/bin/amd64/ngate \"\$@\"
          else
            echo 'NGate client binary not found. Check installation paths.'
            exit 1
          fi
        " -- "$@"
      '';

      # Обёртка для CLI утилит CryptoPro (certmgr, cpconfig и т.д.)
      cryptopro-cli = pkgs.writeShellScriptBin "cryptopro-cli" ''
        exec ${cryptopro-fhs}/bin/cryptopro -c "
          export PATH=/opt/cprocsp/bin/amd64:/opt/cprocsp/sbin/amd64:\$PATH
          export LD_LIBRARY_PATH=/opt/cprocsp/lib/amd64:\$LD_LIBRARY_PATH
          exec \"\$@\"
        " -- "$@"
      '';
    in
    {
      environment.systemPackages = [
        cryptopro-fhs
        ngate-wrapped
        cryptopro-cli
      ];
    };

  flake.modules.homeManager.cryptopro-vpn =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      certDir = "${config.home.homeDirectory}/.config/cryptopro/certs";
    in
    {
      # Создаём директорию для сертификатов
      home.file.".config/cryptopro/certs/.keep".text = ''
        Положите сюда сертификаты:
        - CryproPro_GOST_Root_CA.cer (корневой)
        - CryptoPro_TLS_CA.cer (промежуточный)

        Затем выполните: cryptopro-import-certs
      '';

      # Скрипт импорта сертификатов
      home.packages = [
        (pkgs.writeShellScriptBin "cryptopro-import-certs" ''
          CERT_DIR="${certDir}"

          if [ ! -d "$CERT_DIR" ]; then
            echo "Директория $CERT_DIR не существует"
            exit 1
          fi

          ROOT_CERT="$CERT_DIR/CryproPro_GOST_Root_CA.cer"
          TLS_CERT="$CERT_DIR/CryptoPro_TLS_CA.cer"

          MISSING=0
          if [ ! -f "$ROOT_CERT" ]; then
            echo "SKIP: $ROOT_CERT не найден"
            MISSING=1
          fi
          if [ ! -f "$TLS_CERT" ]; then
            echo "SKIP: $TLS_CERT не найден"
            MISSING=1
          fi

          if [ "$MISSING" -eq 1 ]; then
            echo ""
            echo "Положите сертификаты в $CERT_DIR и запустите скрипт снова."
            exit 0
          fi

          echo "Импорт корневого сертификата..."
          cryptopro-cli /opt/cprocsp/bin/amd64/certmgr -install -store mroot -file "$ROOT_CERT"

          echo "Импорт промежуточного сертификата..."
          cryptopro-cli /opt/cprocsp/bin/amd64/certmgr -install -store mroot -file "$TLS_CERT"

          echo "Готово! Сертификаты импортированы."
        '')
      ];

      # Activation script: импортирует сертификаты если они есть
      home.activation.cryptopro-certs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        CERT_DIR="${certDir}"
        ROOT_CERT="$CERT_DIR/CryproPro_GOST_Root_CA.cer"
        TLS_CERT="$CERT_DIR/CryptoPro_TLS_CA.cer"

        if [ -f "$ROOT_CERT" ] && [ -f "$TLS_CERT" ]; then
          $VERBOSE_ECHO "Importing CryptoPro certificates..."
          ${pkgs.lib.getExe (
            pkgs.writeShellScriptBin "import-certs" ''
              cryptopro-cli /opt/cprocsp/bin/amd64/certmgr -install -store mroot -file "$1" 2>/dev/null || true
              cryptopro-cli /opt/cprocsp/bin/amd64/certmgr -install -store mroot -file "$2" 2>/dev/null || true
            ''
          )} "$ROOT_CERT" "$TLS_CERT"
        else
          $VERBOSE_ECHO "CryptoPro certs not found in $CERT_DIR, skipping import"
        fi
      '';
    };
}
