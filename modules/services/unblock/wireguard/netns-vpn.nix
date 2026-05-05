{
  # Режим 2: только конкретные приложения через VPN (netns)
  flake.modules.nixos.wireguard-netns-vpn =
    { config, pkgs, ... }:
    let
      wgName = config.settings.wireguardConfigName;
    in
    {
      systemd.services.netns-vpn = {
        description = "VPN network namespace";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        # wantedBy намеренно не указан - запускать вручную
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "netns-vpn-start" ''
            CONFFILE="${config.sops.secrets.${wgName}.path}"

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
    };

  flake.modules.homeManager.wireguard-netns-vpn =
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
        wg-app-up = "sudo systemctl start netns-vpn.service";
        wg-app-down = "sudo systemctl stop netns-vpn.service";
        wg-app-status = "sudo systemctl status netns-vpn.service";
        wg-app-restart = "sudo systemctl restart netns-vpn.service";
        wg-app-show = "sudo ip netns exec vpn wg show";
        wg-app-exec = "sudo ip netns exec vpn sudo -u $USER env ${vpnEnv}";
      };
    };
}
