# Корпоративный VPN через CryptoPro NGate в контейнере distrobox.
#
# Вместо упаковки CryptoPro в Nix-деривации, NGate запускается внутри
# обычного Linux-контейнера (Ubuntu) через distrobox. CryptoPro ставится
# стандартным dpkg, работает без патчинга путей — так же, как на обычном Linux.
#
# Первоначальная настройка:
#   1. Добавить пароль VPN в sops: sops secrets/secrets.yaml
#      Ключ: work-vpn-pass
#
#   2. Положить файлы установки в ~/.config/cryptopro/distrobox/:
#        - linux-amd64_deb.tgz  (архив CryptoPro CSP)
#        - ngate-client.deb     (установщик NGate, .deb или self-extracting)
#        - CryproPro_GOST_Root_CA.cer  (корневой сертификат)
#        - CryptoPro_TLS_CA.cer        (промежуточный сертификат)
#
#   3. Запустить: work-vpn-setup
#      Это создаст контейнер и установит всё внутри.
#
#   4. Задать лицензию CryptoPro CSP:
#        work-vpn-exec cpconfig -license -set <ключ-лицензии>
#
# Использование:
#   - work-vpn          — подключиться к VPN
#   - work-vpn-down     — отключиться от VPN
#   - work-vpn-setup    — создать/пересоздать контейнер и установить CryptoPro
#   - work-vpn-exec ... — выполнить команду внутри контейнера

{ inputs, ... }:
{
  flake.modules.nixos.cryptopro-distrobox =
    { config, pkgs, ... }:
    let
      username = config.settings.username;
    in
    {
      # Podman для rootful distrobox-контейнеров
      virtualisation.podman = {
        enable = true;
        dockerCompat = false;
      };

      environment.systemPackages = with pkgs; [
        distrobox
      ];

      users.users.${username}.extraGroups = [ "podman" ];

      sops.secrets."work-vpn-pass" = {
        sopsFile = inputs.self + "/secrets/secrets.yaml";
        key = "work-vpn-pass";
        owner = username;
      };
    };

  flake.modules.homeManager.cryptopro-distrobox =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      containerName = "ngate-root";
      filesDir = "${config.home.homeDirectory}/.config/cryptopro/distrobox";
      certDir = "${config.home.homeDirectory}/.config/cryptopro/certs";
      vpnGateway = "https://global.gw.yadro.com";

      distrobox = "${pkgs.distrobox}/bin/distrobox";

      # Скрипт первоначальной настройки контейнера
      work-vpn-setup = pkgs.writeShellScriptBin "work-vpn-setup" ''
        set -euo pipefail

        FILES_DIR="${filesDir}"
        CERT_DIR="${certDir}"

        echo "=== Создание distrobox-контейнера ${containerName} ==="

        # Проверяем наличие файлов
        MISSING=0
        for f in "$FILES_DIR/linux-amd64_deb.tgz"; do
          if [ ! -f "$f" ]; then
            echo "ОШИБКА: не найден $f"
            MISSING=1
          fi
        done
        if [ "$MISSING" -eq 1 ]; then
          echo ""
          echo "Положите файлы установки в $FILES_DIR:"
          echo "  - linux-amd64_deb.tgz  (CryptoPro CSP)"
          echo "  - ngate-client.deb     (NGate, опционально)"
          echo "  - CryproPro_GOST_Root_CA.cer  (в $CERT_DIR)"
          echo "  - CryptoPro_TLS_CA.cer        (в $CERT_DIR)"
          exit 1
        fi

        # Удаляем старый контейнер если есть
        ${distrobox} stop -Y ${containerName} --root 2>/dev/null || true
        ${distrobox} rm -f ${containerName} --root 2>/dev/null || true

        # Создаём контейнер на базе Ubuntu 22.04
        ${distrobox} create \
          --name ${containerName} \
          --image ubuntu:22.04 \
          --root \
          --yes

        echo "=== Установка CryptoPro CSP ==="
        ${distrobox} enter ${containerName} --root -- sh -c "
          set -e
          apt-get update
          apt-get install -y tar lsb-release

          # Распаковка и установка CSP
          mkdir -p /tmp/cprocsp
          tar -xzf $FILES_DIR/linux-amd64_deb.tgz -C /tmp/cprocsp
          cd /tmp/cprocsp
          if [ -f install.sh ]; then
            chmod +x install.sh
            ./install.sh
          else
            dpkg -i *.deb || apt-get install -f -y
          fi
          rm -rf /tmp/cprocsp
        "

        # Установка NGate если файл есть
        if [ -f "$FILES_DIR/ngate-client.deb" ]; then
          echo "=== Установка NGate ==="
          ${distrobox} enter ${containerName} --root -- sh -c "
            set -e
            dpkg -i $FILES_DIR/ngate-client.deb || apt-get install -f -y
          "
        elif ls "$FILES_DIR"/ngate-client-installer-* 2>/dev/null; then
          INSTALLER=$(ls "$FILES_DIR"/ngate-client-installer-* | head -1)
          echo "=== Установка NGate из $INSTALLER ==="
          ${distrobox} enter ${containerName} --root -- sh -c "
            set -e
            chmod +x $INSTALLER
            $INSTALLER
          "
        else
          echo "ПРЕДУПРЕЖДЕНИЕ: установщик NGate не найден, пропускаю"
        fi

        # Импорт сертификатов
        if [ -f "$CERT_DIR/CryproPro_GOST_Root_CA.cer" ] && [ -f "$CERT_DIR/CryptoPro_TLS_CA.cer" ]; then
          echo "=== Импорт сертификатов ==="
          ${distrobox} enter ${containerName} --root -- sh -c "
            /opt/cprocsp/bin/amd64/certmgr -install -store mroot -file $CERT_DIR/CryproPro_GOST_Root_CA.cer
            /opt/cprocsp/bin/amd64/certmgr -install -store mroot -file $CERT_DIR/CryptoPro_TLS_CA.cer
          "
        else
          echo "ПРЕДУПРЕЖДЕНИЕ: сертификаты не найдены в $CERT_DIR, пропускаю"
          echo "Импортируйте позже: work-vpn-exec certmgr -install -store mroot -file <путь>"
        fi

        echo ""
        echo "=== Готово! ==="
        echo "Для подключения: work-vpn"
      '';

      # Подключение к VPN
      work-vpn = pkgs.writeShellScriptBin "work-vpn" ''
        set -euo pipefail

        WORK_PASS="$(cat /run/secrets/work-vpn-pass)"
        VPN_USER="''${WORK_VPN_USER:-$(whoami)}"

        echo "Подключение к VPN как $VPN_USER..."

        # Останавливаем предыдущую сессию
        ${distrobox} stop -Y ${containerName} --root 2>/dev/null || true

        # Запускаем туннель и подключаемся
        ${distrobox} enter ${containerName} --root -- sh -c "
          sudo /opt/cprongate/ngatetun > /dev/null 2>&1 &
          sleep 1
          sudo /opt/cprongate/ngateconsoleclient \
            -u \"\$1\" \
            -p \"\$2\" \
            -v \
            ${vpnGateway} > /dev/null 2>&1 &
          sleep 15
        " -- "$VPN_USER" "$WORK_PASS"

        # Настраиваем split-DNS на хосте
        if ip link show tun0 &>/dev/null; then
          sudo ${pkgs.systemd}/bin/resolvectl dns tun0 172.31.129.43
          sudo ${pkgs.systemd}/bin/resolvectl domain tun0 "~yadro.com"
          echo "VPN подключен. DNS настроен для *.yadro.com"
        else
          echo "ОШИБКА: интерфейс tun0 не появился. Проверьте логи."
          exit 1
        fi
      '';

      # Отключение от VPN
      work-vpn-down = pkgs.writeShellScriptBin "work-vpn-down" ''
        set -euo pipefail
        echo "Отключение VPN..."
        ${distrobox} stop -Y ${containerName} --root 2>/dev/null || true
        # tun0 пропадёт автоматически после остановки контейнера
        echo "VPN отключен."
      '';

      # Статус VPN
      work-vpn-status = pkgs.writeShellScriptBin "work-vpn-status" ''
        if ip link show tun0 &>/dev/null; then
          echo "VPN: подключен (tun0 active)"
          echo "DNS: $(${pkgs.systemd}/bin/resolvectl status tun0 2>/dev/null | grep 'DNS Servers' || echo 'не настроен')"
        else
          echo "VPN: отключен"
        fi
      '';

      # Выполнение команды внутри контейнера
      work-vpn-exec = pkgs.writeShellScriptBin "work-vpn-exec" ''
        exec ${distrobox} enter ${containerName} --root -- "$@"
      '';
    in
    {
      # Директории для файлов установки и сертификатов
      home.file.".config/cryptopro/distrobox/.keep".text = ''
        Положите сюда файлы установки CryptoPro:
        - linux-amd64_deb.tgz  (CryptoPro CSP)
        - ngate-client.deb     (NGate клиент)
        Затем выполните: work-vpn-setup
      '';

      home.file.".config/cryptopro/certs/.keep".text = ''
        Положите сюда сертификаты:
        - CryproPro_GOST_Root_CA.cer (корневой)
        - CryptoPro_TLS_CA.cer (промежуточный)
      '';

      home.packages = [
        work-vpn-setup
        work-vpn
        work-vpn-down
        work-vpn-status
        work-vpn-exec
      ];

      programs.zsh.shellAliases = {
        wvpn = "work-vpn";
        wvpnd = "work-vpn-down";
        wvpns = "work-vpn-status";
      };
    };
}
