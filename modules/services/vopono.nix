{ inputs, ... }:

{

  flake.modules.nixos.vopono =

    { config, pkgs, ... }:

    {

      # 1. Секрет с конфигом WireGuard (оставляем как есть)
      sops.secrets.wireguard = {

        sopsFile = inputs.self + "/secrets/wireguard.conf";

        format = "binary";

      };

      # 2. Установка необходимых пакетов
      environment.systemPackages = with pkgs; [

        vopono

        wireguard-tools # Требуется для работы WireGuard внутри vopono

      ];

      # 3. Настройка системного демона vopono
      # Это позволяет запускать vopono без sudo (или с минимальными правами)
      systemd.services.vopono = {

        description = "Vopono root daemon";

        after = [ "network.target" ];

        requires = [ "network.target" ];

        # Раскомментируйте следующую строку, если хотите, чтобы демон стартовал при загрузке:
        # wantedBy = [ "multi-user.target" ];

        serviceConfig = {

          Type = "simple";

          ExecStart = "${pkgs.vopono}/bin/vopono daemon";

          Restart = "on-failure";

          RestartSec = "2s";

          # Опционально: логирование для отладки
          Environment = "RUST_LOG=info";

        };

      };

      # Примечание по фаерволу: vopono использует iptables или nftables.
      # Убедитесь, что у вас включен один из них, или разрешите vopono управлять правилами.
      # networking.nftables.enable = true;

    };

  flake.modules.homeManager.vopono =

    { ... }:

    {

      programs.zsh.shellAliases = {

        # Управление демоном vopono
        vpu = "sudo systemctl start vopono.service";
        vpd = "sudo systemctl stop vopono.service";
        vpr = "sudo systemctl restart vopono.service";
        vps = "systemctl status vopono.service";

        # Аналог 'proxied' для vopono
        # Запускает команду в namespace с вашим кастомным WireGuard конфигом
        # Пример использования: vp firefox
        # Путь /run/secrets/wireguard соответствует sops.secrets.wireguard.path
        vp = "vopono exec --custom /run/secrets/wireguard --protocol wireguard";

      };

    };

}
