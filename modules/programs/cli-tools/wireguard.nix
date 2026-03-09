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
      ];

      systemd.services.netns-vpn = {
        description = "VPN network namespace";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "netns-vpn-start" ''
            # Создать namespace
            ${pkgs.iproute2}/bin/ip netns add vpn
            ${pkgs.iproute2}/bin/ip -n vpn link set lo up

            # Создать wg интерфейс и перенести в namespace
            ${pkgs.iproute2}/bin/ip link add wg0 type wireguard
            ${pkgs.iproute2}/bin/ip link set wg0 netns vpn

            # Создать временный конфиг без Address/DNS
            TMPCONF=$(mktemp)
            grep -v "^Address\|^DNS" ${config.sops.secrets.wireguard.path} > $TMPCONF

            # Настроить wireguard
            ${pkgs.iproute2}/bin/ip netns exec vpn \
              ${pkgs.wireguard-tools}/bin/wg setconf wg0 $TMPCONF
            rm $TMPCONF

            # Задать IP вручную
            ${pkgs.iproute2}/bin/ip -n vpn addr add 10.0.0.2/32 dev wg0
            ${pkgs.iproute2}/bin/ip -n vpn link set wg0 up
            ${pkgs.iproute2}/bin/ip -n vpn route add default dev wg0

            # DNS
            mkdir -p /etc/netns/vpn
            echo "nameserver 8.8.8.8" > /etc/netns/vpn/resolv.conf
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

  flake.modules.homeManager.wireguard =
    { ... }:
    {
      programs.zsh.shellAliases = {
        wgu = "sudo systemctl start netns-vpn.service";
        wgd = "sudo systemctl stop netns-vpn.service";
        wgs = "sudo systemctl status netns-vpn.service";
        vpn-run = "sudo ip netns exec vpn sudo -u $USER env WAYLAND_DISPLAY=$WAYLAND_DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR DISPLAY=$DISPLAY DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS";
      };
    };
}
