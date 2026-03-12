{ inputs, ... }:
{
  flake.modules.nixos.wireguard =
    { config, pkgs, ... }:
    {
      sops.secrets.wireguard = {
        sopsFile = inputs.self + "/secrets/wireguard.conf";
        format = "binary";
      };

      networking.firewall.checkReversePath = "loose";

      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
      };

      environment.systemPackages = with pkgs; [
        wireguard-tools
        iproute2
        iptables
      ];

      # Режим 1: весь трафик через VPN (wg-quick)
      networking.wg-quick.interfaces.wg0 = {
        configFile = config.sops.secrets.wireguard.path;
        autostart = false;
      };

      # Режим 2: только конкретные приложения через VPN (netns)
      systemd.services.netns-vpn = {
        description = "VPN network namespace";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        # wantedBy намеренно не указан - запускать вручную
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "netns-vpn-start" ''
            CONFFILE="${config.sops.secrets.wireguard.path}"

            # Парсим Address и DNS из конфига (tr -d '\r' на случай Windows line endings)
            WG_ADDRESS=$(grep "^Address" "$CONFFILE" | head -1 | sed 's/.*= *//' | tr -d ' \r')
            WG_DNS=$(grep "^DNS" "$CONFFILE" | head -1 | sed 's/.*= *//' | tr -d ' \r')

            echo "Using address: '$WG_ADDRESS'"
            echo "Using DNS: '$WG_DNS'"

            # Создать namespace
            ${pkgs.iproute2}/bin/ip netns add vpn
            ${pkgs.iproute2}/bin/ip -n vpn link set lo up

            # Создать wg интерфейс и перенести в namespace
            ${pkgs.iproute2}/bin/ip link add wg0 type wireguard
            ${pkgs.iproute2}/bin/ip link set wg0 netns vpn

            # Создать временный конфиг без Address/DNS (wg не понимает эти поля)
            TMPCONF=$(mktemp)
            grep -v "^Address\|^DNS" "$CONFFILE" | tr -d '\r' > $TMPCONF

            # Настроить wireguard
            ${pkgs.iproute2}/bin/ip netns exec vpn \
              ${pkgs.wireguard-tools}/bin/wg setconf wg0 $TMPCONF 2>/dev/null
            rm $TMPCONF

            # Задать IP из конфига
            ${pkgs.iproute2}/bin/ip -n vpn addr add "$WG_ADDRESS" dev wg0 && echo "addr add OK" || echo "addr add FAILED"
            ${pkgs.iproute2}/bin/ip -n vpn link set wg0 up
            ${pkgs.iproute2}/bin/ip -n vpn route add default dev wg0

            # DNS из конфига
            mkdir -p /etc/netns/vpn
            echo "nameserver $WG_DNS" > /etc/netns/vpn/resolv.conf
            chmod -R o+rX /etc/netns
          '';
          ExecStop = pkgs.writeShellScript "netns-vpn-stop" ''
            ${pkgs.iproute2}/bin/ip netns pids vpn | xargs -r kill
            ${pkgs.iproute2}/bin/ip netns del vpn 2>/dev/null || true
            rm -rf /etc/netns/vpn
          '';
        };
      };

      # Режим 3: весь трафик через VPN, кроме приложений в namespace bypass
      # Требует: vpn-full-up (wg-quick) уже запущен
      systemd.services.netns-bypass = {
        description = "Bypass VPN network namespace";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "netns-bypass-start" ''
            # IP root-стороны veth (в корневом namespace)
            ROOT_IP="10.99.99.4"
            # IP namespace-стороны veth (в namespace bypass)
            NS_IP="10.99.99.5"

            # Создать namespace и поднять loopback
            ${pkgs.iproute2}/bin/ip netns add bypass
            ${pkgs.iproute2}/bin/ip -n bypass link set lo up

            # Создать veth-пару: to-bypass в root, from-bypass в bypass
            ${pkgs.iproute2}/bin/ip link add to-bypass type veth peer name from-bypass netns bypass

            # Настроить root-сторону
            ${pkgs.iproute2}/bin/ip address add "$ROOT_IP/31" dev to-bypass
            ${pkgs.iproute2}/bin/ip link set to-bypass up

            # Настроить namespace-сторону
            ${pkgs.iproute2}/bin/ip -n bypass address add "$NS_IP/31" dev from-bypass
            ${pkgs.iproute2}/bin/ip -n bypass link set from-bypass up

            # Маршрут по умолчанию в namespace — через root
            ${pkgs.iproute2}/bin/ip -n bypass route add default via "$ROOT_IP"

            # Policy routing: пакеты из bypass-namespace идут по main table,
            # минуя WireGuard (у wg-quick таблица 51820 с приоритетом < 99)
            ${pkgs.iproute2}/bin/ip rule add from "$NS_IP" table main priority 99

            # NAT: маскарадинг исходящих пакетов из namespace
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s "$NS_IP" -j MASQUERADE

            # Firewall: разрешить форвардинг из/в namespace
            ${pkgs.iptables}/bin/iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
            ${pkgs.iptables}/bin/iptables -A FORWARD -s "$NS_IP" -j ACCEPT

            # DNS: использовать публичный резолвер (не localhost systemd-resolved)
            mkdir -p /etc/netns/bypass
            echo "nameserver 9.9.9.9" > /etc/netns/bypass/resolv.conf
            chmod -R o+rX /etc/netns
          '';
          ExecStop = pkgs.writeShellScript "netns-bypass-stop" ''
            NS_IP="10.99.99.5"

            # Убрать правила iptables
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s "$NS_IP" -j MASQUERADE 2>/dev/null || true
            ${pkgs.iptables}/bin/iptables -D FORWARD -s "$NS_IP" -j ACCEPT 2>/dev/null || true
            ${pkgs.iptables}/bin/iptables -D FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true

            # Убрать policy routing rule
            ${pkgs.iproute2}/bin/ip rule del from "$NS_IP" table main priority 99 2>/dev/null || true

            # Завершить процессы и удалить namespace
            ${pkgs.iproute2}/bin/ip netns pids bypass | xargs -r kill
            ${pkgs.iproute2}/bin/ip netns del bypass 2>/dev/null || true

            rm -rf /etc/netns/bypass
          '';
        };
      };
    };

  flake.modules.homeManager.wireguard =
    { lib, ... }:
    let
      vpnEnv = lib.concatStringsSep " " [
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
    in
    {
      programs.zsh.shellAliases = {
        # Режим 1: весь трафик через VPN
        vpn-full-up = "sudo systemctl start wg-quick-wg0.service";
        vpn-full-down = "sudo systemctl stop wg-quick-wg0.service";
        vpn-full-status = "sudo systemctl status wg-quick-wg0.service";

        # Режим 2: только конкретные приложения через VPN (netns vpn)
        vpn-app-up = "sudo systemctl start netns-vpn.service";
        vpn-app-down = "sudo systemctl stop netns-vpn.service";
        vpn-app-status = "sudo systemctl status netns-vpn.service";
        vpn-app-show = "sudo ip netns exec vpn wg show";
        vpn-app-exec = "sudo ip netns exec vpn sudo -u $USER env ${vpnEnv}";

        # Режим 3: весь трафик через VPN (wg-quick), кроме приложений в bypass
        # Порядок: сначала vpn-full-up, потом vpn-bypass-up
        vpn-bypass-up = "sudo systemctl start netns-bypass.service";
        vpn-bypass-down = "sudo systemctl stop netns-bypass.service";
        vpn-bypass-status = "sudo systemctl status netns-bypass.service";
        # Запустить приложение в обход VPN:
        vpn-bypass-exec = "sudo ip netns exec bypass sudo -u $USER env ${vpnEnv}";
      };
    };
}
