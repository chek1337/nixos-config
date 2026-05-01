{ inputs, ... }:
let
  nsName = "vlpn0";
  hostVeth = "vlpn-host";
  nsVeth = "vlpn-ns";
  hostIP = "10.99.99.1";
  nsIP = "10.99.99.2";
  cidr = "30";
  tunSubnet = "172.19.0.1/30";
  tunIface = "vlpn-tun";
in
{
  flake.modules.nixos.vlpn =
    {
      config,
      pkgs,
      ...
    }:
    let
      parserScript = pkgs.writeText "vless-to-singbox.py" ''
        import ipaddress
        import json
        import sys
        from urllib.parse import urlparse, parse_qs

        url = sys.stdin.read().strip()
        u = urlparse(url)
        if u.scheme != "vless":
            sys.exit(f"unsupported scheme: {u.scheme!r}")

        q = {k: v[0] for k, v in parse_qs(u.query).items()}
        transport_type = q.get("type", "tcp")
        security = q.get("security", "none")
        sni = q.get("sni", u.hostname)

        outbound = {
            "type": "vless",
            "tag": "vless-out",
            "server": u.hostname,
            "server_port": u.port or 443,
            "uuid": u.username,
        }

        flow = q.get("flow")
        if flow:
            outbound["flow"] = flow

        if security in ("tls", "reality"):
            tls = {"enabled": True, "server_name": sni}
            fp = q.get("fp")
            if fp:
                tls["utls"] = {"enabled": True, "fingerprint": fp}
            if security == "reality":
                tls["reality"] = {
                    "enabled": True,
                    "public_key": q["pbk"],
                    "short_id": q.get("sid", ""),
                }
            outbound["tls"] = tls

        if transport_type == "ws":
            outbound["transport"] = {
                "type": "ws",
                "path": q.get("path", "/"),
                "headers": {"Host": q.get("host", sni)},
            }
        elif transport_type == "grpc":
            outbound["transport"] = {
                "type": "grpc",
                "service_name": q.get("serviceName", ""),
            }

        try:
            ipaddress.ip_address(u.hostname)
            direct_rule = {"ip_cidr": [f"{u.hostname}/32"], "outbound": "direct-out"}
        except ValueError:
            direct_rule = {"domain": [u.hostname], "outbound": "direct-out"}

        cfg = {
            "log": {"level": "info", "timestamp": True},
            "dns": {
                "servers": [
                    {"type": "udp", "tag": "remote", "server": "1.1.1.1", "detour": "vless-out"},
                    {"type": "udp", "tag": "local", "server": "8.8.8.8", "detour": "direct-out"},
                ],
                "rules": [
                    {"server": "local", "outbound": ["direct-out"]},
                ],
                "strategy": "ipv4_only",
            },
            "inbounds": [
                {
                    "type": "tun",
                    "tag": "tun-in",
                    "interface_name": "${tunIface}",
                    "address": ["${tunSubnet}"],
                    "auto_route": True,
                    "strict_route": False,
                    "stack": "system",
                }
            ],
            "outbounds": [
                outbound,
                {"type": "direct", "tag": "direct-out"},
            ],
            "route": {
                "rules": [direct_rule],
                "auto_detect_interface": True,
                "final": "vless-out",
            },
        }
        json.dump(cfg, sys.stdout, indent=2)
      '';

      netnsUp = pkgs.writeShellScript "vlpn-netns-up" ''
        set -eu
        IP=${pkgs.iproute2}/bin/ip

        # Recreate cleanly in case of leftover state from a crashed run.
        $IP netns del ${nsName} 2>/dev/null || true
        $IP link del ${hostVeth} 2>/dev/null || true

        $IP netns add ${nsName}
        $IP link add ${hostVeth} type veth peer name ${nsVeth}
        $IP link set ${nsVeth} netns ${nsName}

        $IP addr add ${hostIP}/${cidr} dev ${hostVeth}
        $IP link set ${hostVeth} up

        $IP -n ${nsName} addr add ${nsIP}/${cidr} dev ${nsVeth}
        $IP -n ${nsName} link set ${nsVeth} up
        $IP -n ${nsName} link set lo up
        $IP -n ${nsName} route add default via ${hostIP}
      '';

      netnsDown = pkgs.writeShellScript "vlpn-netns-down" ''
        IP=${pkgs.iproute2}/bin/ip
        $IP netns del ${nsName} 2>/dev/null || true
        $IP link del ${hostVeth} 2>/dev/null || true
      '';

      vlpnExec = pkgs.writeShellScript "vlpn-exec" ''
        set -eu
        if [ -z "''${SUDO_USER:-}" ]; then
          echo "vlpn-exec must be invoked via sudo" >&2
          exit 1
        fi
        exec ${pkgs.iproute2}/bin/ip netns exec ${nsName} \
          ${pkgs.util-linux}/bin/runuser -u "$SUDO_USER" --preserve-environment -- "$@"
      '';
    in
    {
      sops.secrets."vless-chumakov" = {
        sopsFile = inputs.self + "/secrets/secrets.yaml";
        key = "vless-chumakov";
        owner = config.settings.username;
      };

      environment.systemPackages = [
        pkgs.iproute2
        pkgs.util-linux
      ];

      networking.nat = {
        enable = true;
        internalInterfaces = [ hostVeth ];
      };
      networking.firewall.trustedInterfaces = [ hostVeth ];

      systemd.services.vlpn-netns = {
        description = "vlpn0 netns + veth + lo";
        after = [ "network-pre.target" ];
        before = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = netnsUp;
          ExecStop = netnsDown;
        };
      };

      systemd.services.singbox-vless = {
        description = "sing-box VLESS in vlpn0 netns";
        after = [
          "vlpn-netns.service"
          "network-online.target"
        ];
        requires = [ "vlpn-netns.service" ];
        bindsTo = [ "vlpn-netns.service" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = 5;
          NetworkNamespacePath = "/var/run/netns/${nsName}";
          RuntimeDirectory = "singbox-vless";
          RuntimeDirectoryMode = "0700";
          AmbientCapabilities = [
            "CAP_NET_ADMIN"
            "CAP_NET_BIND_SERVICE"
            "CAP_NET_RAW"
          ];

          ExecStartPre = pkgs.writeShellScript "singbox-vless-prepare" ''
            ${pkgs.python3}/bin/python3 ${parserScript} \
              < ${config.sops.secrets."vless-chumakov".path} \
              > /run/singbox-vless/config.json
            chmod 600 /run/singbox-vless/config.json
          '';

          ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /run/singbox-vless/config.json";

          ExecStopPost = pkgs.writeShellScript "singbox-vless-cleanup" ''
            rm -f /run/singbox-vless/config.json
          '';
        };
      };

      security.sudo.extraRules = [
        {
          users = [ config.settings.username ];
          commands = [
            {
              command = "${vlpnExec}";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
          ];
        }
      ];

      environment.etc."vlpn/exec".source = vlpnExec;
    };

  flake.modules.homeManager.vlpn =
    { pkgs, ... }:
    let
      vlpn = pkgs.writeShellApplication {
        name = "vlpn";
        runtimeInputs = [ pkgs.sudo ];
        text = ''
          if [ $# -eq 0 ]; then
            echo "usage: vlpn <command> [args...]" >&2
            echo "Runs COMMAND inside the ${nsName} netns whose default route is the VLESS tunnel." >&2
            exit 1
          fi
          exec sudo \
            --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR,DBUS_SESSION_BUS_ADDRESS,PULSE_SERVER,QT_QPA_PLATFORM,GTK_USE_PORTAL \
            /etc/vlpn/exec "$@"
        '';
      };
    in
    {
      home.packages = [ vlpn ];

      programs.zsh.shellAliases = {
        vlpn-up = "sudo systemctl start singbox-vless.service";
        vlpn-down = "sudo systemctl stop singbox-vless.service";
        vlpn-status = "systemctl status singbox-vless.service vlpn-netns.service";
        vlpn-restart = "sudo systemctl restart singbox-vless.service";
        vlpn-logs = "journalctl -u singbox-vless.service -f";
        vlpn-config = "sudo cat /run/singbox-vless/config.json";
      };
    };
}
