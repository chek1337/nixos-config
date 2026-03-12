{ inputs, ... }:
{
  # =========================================================================
  # NixOS module: vopono daemon + system dependencies
  # Не конфликтует с flake.modules.nixos.wireguard:
  #   - не переопределяет sops.secrets.wireguard
  #   - не трогает namespaces vpn / bypass
  #   - не дублирует wireguard-tools, iproute2, iptables
  # =========================================================================
  flake.modules.nixos.vopono =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # vopono читает конфиг из sops — он уже объявлен в модуле wireguard,
      # здесь только ссылаемся на путь через config.sops.secrets.wireguard.path
      assertions = [
        {
          assertion = config.sops.secrets ? wireguard;
          message = "flake.modules.nixos.vopono требует flake.modules.nixos.wireguard (sops secret 'wireguard')";
        }
      ];

      environment.systemPackages = with pkgs; [
        vopono
      ];

      # Демон vopono — слушает /run/vopono.sock,
      # принимает exec-запросы от обычного пользователя.
      # Не конфликтует с netns-vpn / netns-bypass:
      # vopono создаёт свои namespaces с префиксом vo_*
      systemd.services.vopono-daemon = {
        description = "Vopono root daemon";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        # Не запускается автоматически — включай вручную если нужно:
        # sudo systemctl enable --now vopono-daemon
        # wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.vopono}/bin/vopono daemon";
          Restart = "on-failure";
          RestartSec = "2s";
          Environment = "RUST_LOG=info";
        };
      };

      # Sudo-правило для vopono без демона (fallback).
      # Не дублирует правила ip netns exec vpn/bypass из wireguard-модуля.
      security.sudo.extraRules = [
        {
          users = [ "vo" ]; # замени на своего пользователя
          commands = [
            {
              command = "${pkgs.vopono}/bin/vopono *";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };

  # =========================================================================
  # Home Manager module: алиасы и враппер-скрипты для vopono
  # Все алиасы с префиксом vopono-* — не пересекаются с vpn-* из wireguard
  # =========================================================================
  flake.modules.homeManager.vopono =
    {
      lib,
      pkgs,
      config,
      osConfig,
      ...
    }:
    let
      # Путь до wireguard-конфига берём из NixOS через osConfig.
      # Это тот же sops secret что в wireguard-модуле — не дублируем.
      wgConf = osConfig.sops.secrets.wireguard.path;

      # Env-переменные для Wayland/X11 — аналогично vpnEnv в wireguard-модуле,
      # но вынесены отдельно чтобы не зависеть от него.
      voponoEnv = lib.concatStringsSep " " [
        "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
        "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
        "DISPLAY=$DISPLAY"
        "DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS"
        "QT_QPA_PLATFORMTHEME=$QT_QPA_PLATFORMTHEME"
        "QT_STYLE_OVERRIDE=$QT_STYLE_OVERRIDE"
        "XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP"
        "XDG_SESSION_TYPE=$XDG_SESSION_TYPE"
        "XDG_DATA_DIRS=$XDG_DATA_DIRS"
        "XDG_CONFIG_DIRS=$XDG_CONFIG_DIRS"
        "QT_PLUGIN_PATH=$QT_PLUGIN_PATH"
      ];

      # Базовая команда vopono с кастомным конфигом.
      # Если демон запущен — vopono CLI сам его найдёт по /run/vopono.sock.
      # Если нет — упадёт на sudo (правило выше).
      voponoBase = "vopono exec --protocol wireguard --custom ${wgConf}";

      # Хелпер для враппер-скриптов — аналог mkNsWrapper из wireguard-модуля,
      # но использует vopono вместо прямого ip netns exec.
      mkVoponoWrapper =
        {
          name,
          bin,
          extraArgs ? "",
        }:
        pkgs.writeShellScriptBin name ''
          exec ${voponoBase} ${extraArgs} \
            env ${voponoEnv} \
            ${bin} "$@"
        '';
    in
    {
      home.packages = [
        # Firefox через vopono (отдельный namespace от firefox-vpn / firefox-bypass)
        (mkVoponoWrapper {
          name = "firefox-vopono";
          bin = "firefox";
        })

        # Пример с портом — для торрент-клиента
        # (mkVoponoWrapper {
        #   name     = "transmission-vopono";
        #   bin      = "transmission-gtk";
        #   extraArgs = "-f 9091";
        # })
      ];

      xdg.desktopEntries = {
        firefox-vopono = {
          name = "Firefox (vopono WireGuard)";
          exec = "firefox-vopono %U";
          icon = "firefox";
          comment = "Firefox через vopono daemon (требует vopono-daemon-up)";
          categories = [
            "Network"
            "WebBrowser"
          ];
        };
      };

      programs.zsh.shellAliases = {
        # --- Управление демоном vopono ---
        vopono-daemon-up = "sudo systemctl start vopono-daemon.service";
        vopono-daemon-down = "sudo systemctl stop vopono-daemon.service";
        vopono-daemon-status = "sudo systemctl status vopono-daemon.service";
        vopono-daemon-logs = "sudo journalctl -u vopono-daemon -e";

        # --- Запуск приложений через vopono ---
        # Используй как: vopono-exec firefox
        #                vopono-exec -- curl ifconfig.co
        vopono-exec = "${voponoBase}";

        # --- Диагностика ---
        vopono-list = "vopono list namespaces";
        vopono-apps = "vopono list applications";

        # Показать доступные серверы если используешь провайдера
        # vopono-servers = "vopono servers mullvad --prefix usa";
      };
    };
}
