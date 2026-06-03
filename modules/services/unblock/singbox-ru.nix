{ config, ... }:
let
  nixosMods = config.flake.modules.nixos;
in
{
  flake.modules.nixos.singbox-ru =
    {
      config,
      pkgs,
      ...
    }:
    let
      # Both rule-sets taken from nixpkgs packages (local, no download needed).
      geoipRuSrs = "${pkgs.sing-geoip}/share/sing-box/rule-set/geoip-ru.srs";
      geositeRuSrs = "${pkgs.sing-geosite}/share/sing-box/rule-set/geosite-category-ru.srs";

      parserScript = pkgs.writeText "vless-to-singbox-ru.py" # py
      ''
        import ipaddress
        import json
        import sys
        from urllib.parse import urlparse, parse_qs

        url = sys.stdin.read().strip()
        u = urlparse(url)
        if u.scheme != "vless":
            sys.exit(f"unsupported scheme: {u.scheme!r}")

        q = {k: v[0] for k, v in parse_qs(u.query).items()}
        security = q.get("security", "none")
        sni = q.get("sni", u.hostname)
        transport_type = q.get("type", "tcp")

        outbound = {
            "type": "vless",
            "tag": "proxy",
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

        # Proxy server itself must not loop back through the tunnel
        server_bypass = []
        try:
            ipaddress.ip_address(u.hostname)
            server_bypass.append({"ip_cidr": [f"{u.hostname}/32"], "outbound": "direct"})
        except ValueError:
            server_bypass.append({"domain": [u.hostname], "outbound": "direct"})

        cfg = {
            "log": {"level": "info", "timestamp": True},
            "dns": {
                "servers": [
                    {
                        "type": "udp",
                        "tag": "dns-direct",
                        "server": "77.88.8.8",
                        "detour": "direct",
                    },
                    {
                        "type": "udp",
                        "tag": "dns-proxy",
                        "server": "1.1.1.1",
                        "detour": "proxy",
                    },
                ],
                "rules": [
                    {"rule_set": ["geosite-ru"], "server": "dns-direct"},
                ],
                "final": "dns-proxy",
                "strategy": "ipv4_only",
            },
            "inbounds": [
                {
                    "type": "tun",
                    "tag": "tun-in",
                    "address": ["172.19.0.1/30"],
                    "auto_route": True,
                    "strict_route": False,
                    "stack": "gvisor",
                }
            ],
            "outbounds": [
                outbound,
                {"type": "direct", "tag": "direct", "routing_mark": 100},
            ],
            "route": {
                "rule_set": [
                    {
                        "type": "local",
                        "tag": "geoip-ru",
                        "format": "binary",
                        "path": "${geoipRuSrs}",
                    },
                    {
                        "type": "local",
                        "tag": "geosite-ru",
                        "format": "binary",
                        "path": "${geositeRuSrs}",
                    },
                ],
                "rules": [
                    {"port": 53, "action": "hijack-dns"},
                    {"ip_is_private": True, "outbound": "direct"},
                    *server_bypass,
                    {"rule_set": ["geoip-ru"], "outbound": "direct"},
                    {"rule_set": ["geosite-ru"], "outbound": "direct"},
                ],
                "final": "proxy",
                "auto_detect_interface": True,
                "default_domain_resolver": "dns-direct",
            },
        }

        json.dump(cfg, sys.stdout, indent=2)
      '';
    in
    {
      imports = [ nixosMods.unblock-vless-secret ];

      systemd.services.singbox-ru = {
        description = "sing-box VLESS transparent proxy — RU direct, rest tunnelled";
        after = [
          "network-online.target"
          "sops-nix.service"
        ];
        wants = [ "network-online.target" ];
        # No wantedBy — start manually with: sb-up
        restartIfChanged = false;

        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = 5;
          RuntimeDirectory = "singbox-ru";
          RuntimeDirectoryMode = "0700";

          ExecStartPre = pkgs.writeShellScript "singbox-ru-prepare" ''
            ${pkgs.python3}/bin/python3 ${parserScript} \
              < ${config.sops.secrets."vless-chumakov".path} \
              > /run/singbox-ru/config.json
            chmod 600 /run/singbox-ru/config.json
          '';

          ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /run/singbox-ru/config.json";

          ExecStopPost = pkgs.writeShellScript "singbox-ru-cleanup" ''
            rm -f /run/singbox-ru/config.json
          '';
        };
      };
    };

  flake.modules.homeManager.singbox-ru =
    { ... }:
    {
      programs.zsh.shellAliases = {
        sb-up = "sudo systemctl start singbox-ru.service";
        sb-down = "sudo systemctl stop singbox-ru.service";
        sb-status = "systemctl status singbox-ru.service";
        sb-restart = "sudo systemctl restart singbox-ru.service";
        sb-logs = "journalctl -u singbox-ru.service -f";
        sb-config = "sudo cat /run/singbox-ru/config.json";
      };
    };
}
