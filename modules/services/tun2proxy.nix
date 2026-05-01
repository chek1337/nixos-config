{ inputs, ... }:
{
  flake.modules.nixos.tun2proxy =
    {
      config,
      pkgs,
      ...
    }:
    let
      parserScript = pkgs.writeText "vless-to-singbox.py" ''
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

        cfg = {
            "log": {"level": "info", "timestamp": True},
            "inbounds": [
                {
                    "type": "socks",
                    "tag": "socks-in",
                    "listen": "127.0.0.1",
                    "listen_port": 1080,
                }
            ],
            "outbounds": [outbound],
        }
        json.dump(cfg, sys.stdout, indent=2)
      '';
    in
    {
      sops.secrets."vless-chumakov" = {
        sopsFile = inputs.self + "/secrets/secrets.yaml";
        key = "vless-chumakov";
        owner = config.settings.username;
      };

      environment.systemPackages = [ pkgs.tun2proxy ];

      systemd.services.singbox-vless = {
        description = "sing-box VLESS to SOCKS5 bridge";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = 5;
          RuntimeDirectory = "singbox-vless";
          RuntimeDirectoryMode = "0700";

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
    };

  flake.modules.homeManager.tun2proxy =
    { pkgs, ... }:
    let
      vlpn = pkgs.writeShellApplication {
        name = "vlpn";
        runtimeInputs = [ pkgs.tun2proxy ];
        text = ''
          if [ $# -eq 0 ]; then
            echo "usage: vlpn <command> [args...]" >&2
            echo "Runs COMMAND inside a netns whose only egress is socks5://127.0.0.1:1080" >&2
            exit 1
          fi
          exec tun2proxy-bin \
            --proxy socks5://127.0.0.1:1080 \
            --setup \
            --unshare \
            -- "$@"
        '';
      };
    in
    {
      home.packages = [ vlpn ];

      programs.zsh.shellAliases = {
        vlpn-up = "sudo systemctl start singbox-vless.service";
        vlpn-down = "sudo systemctl stop singbox-vless.service";
        vlpn-status = "systemctl status singbox-vless.service";
        vlpn-restart = "sudo systemctl restart singbox-vless.service";
      };
    };
}
