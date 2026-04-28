{
  # Режим 3: весь трафик через VPN, кроме приложений в namespace bypass
  # Требует: vpn-full-up (wg-quick) уже запущен
  flake.modules.nixos.wireguard-netns-bypass =
    { pkgs-stable, ... }:
    {
      systemd.services.netns-bypass = {
        description = "Bypass VPN network namespace";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs-stable.writeShellScript "netns-bypass-start" ''
            # IP root-стороны veth (в корневом namespace)
            ROOT_IP="10.99.99.4"
            # IP namespace-стороны veth (в namespace bypass)
            NS_IP="10.99.99.5"

            # Создать namespace и поднять loopback
            ${pkgs-stable.iproute2}/bin/ip netns add bypass
            ${pkgs-stable.iproute2}/bin/ip -n bypass link set lo up

            # Создать veth-пару: to-bypass в root, from-bypass в bypass
            ${pkgs-stable.iproute2}/bin/ip link add to-bypass type veth peer name from-bypass netns bypass

            # Настроить root-сторону
            ${pkgs-stable.iproute2}/bin/ip address add "$ROOT_IP/31" dev to-bypass
            ${pkgs-stable.iproute2}/bin/ip link set to-bypass up

            # Настроить namespace-сторону
            ${pkgs-stable.iproute2}/bin/ip -n bypass address add "$NS_IP/31" dev from-bypass
            ${pkgs-stable.iproute2}/bin/ip -n bypass link set from-bypass up

            # Маршрут по умолчанию в namespace — через root
            ${pkgs-stable.iproute2}/bin/ip -n bypass route add default via "$ROOT_IP"

            # Policy routing: пакеты из bypass-namespace идут по main table,
            # минуя WireGuard (у wg-quick таблица 51820 с приоритетом < 99)
            ${pkgs-stable.iproute2}/bin/ip rule add from "$NS_IP" table main priority 99

            # NAT: маскарадинг исходящих пакетов из namespace
            ${pkgs-stable.iptables}/bin/iptables -t nat -A POSTROUTING -s "$NS_IP" -j MASQUERADE

            # Firewall: разрешить форвардинг из/в namespace
            ${pkgs-stable.iptables}/bin/iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
            ${pkgs-stable.iptables}/bin/iptables -A FORWARD -s "$NS_IP" -j ACCEPT

            # DNS: использовать публичный резолвер (не localhost systemd-resolved)
            mkdir -p /etc/netns/bypass
            echo "nameserver 9.9.9.9" > /etc/netns/bypass/resolv.conf
            chmod -R o+rX /etc/netns
          '';
          ExecStop = pkgs-stable.writeShellScript "netns-bypass-stop" ''
            NS_IP="10.99.99.5"

            # Убрать правила iptables
            ${pkgs-stable.iptables}/bin/iptables -t nat -D POSTROUTING -s "$NS_IP" -j MASQUERADE 2>/dev/null || true
            ${pkgs-stable.iptables}/bin/iptables -D FORWARD -s "$NS_IP" -j ACCEPT 2>/dev/null || true
            ${pkgs-stable.iptables}/bin/iptables -D FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true

            # Убрать policy routing rule
            ${pkgs-stable.iproute2}/bin/ip rule del from "$NS_IP" table main priority 99 2>/dev/null || true

            # Завершить процессы и удалить namespace
            ${pkgs-stable.iproute2}/bin/ip netns pids bypass | xargs -r kill
            ${pkgs-stable.iproute2}/bin/ip netns del bypass 2>/dev/null || true

            rm -rf /etc/netns/bypass
          '';
        };
      };
    };

  flake.modules.homeManager.wireguard-netns-bypass =
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
      # Порядок: сначала wg-full-up, потом wg-bypass-up
      programs.zsh.shellAliases = {
        wg-bypass-up = "sudo systemctl start netns-bypass.service";
        wg-bypass-down = "sudo systemctl stop netns-bypass.service";
        wg-bypass-status = "sudo systemctl status netns-bypass.service";
        wg-bypass-restart = "sudo systemctl restart netns-bypass.service";
        wg-bypass-exec = "sudo ip netns exec bypass sudo -u $USER env ${vpnEnv}";
      };
    };
}
