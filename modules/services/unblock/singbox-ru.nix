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

      # Accepts either a vless:// URL or a WireGuard config on stdin and emits a
      # sing-box config. A VLESS upstream becomes a "proxy" outbound; a WireGuard
      # upstream becomes a "proxy" wireguard endpoint (sing-box >=1.11, endpoint
      # tags are usable as outbounds). The RU-direct routing is shared by both.
      parserScript =
        pkgs.writeText "upstream-to-singbox-ru.py" # py
          ''
            import ipaddress
            import json
            import sys
            from urllib.parse import urlparse, parse_qs

            text = sys.stdin.read().strip()

            proxy_outbound = None
            proxy_endpoint = None
            server_bypass = []


            def bypass_rule(host):
                # The upstream server itself must not loop back through the tunnel.
                try:
                    ipaddress.ip_address(host)
                    return {"ip_cidr": [f"{host}/32"], "outbound": "direct"}
                except ValueError:
                    return {"domain": [host], "outbound": "direct"}


            def parse_vless(url):
                u = urlparse(url)
                q = {k: v[0] for k, v in parse_qs(u.query).items()}
                security = q.get("security", "none")
                sni = q.get("sni", u.hostname)
                transport_type = q.get("type", "tcp")

                ob = {
                    "type": "vless",
                    "tag": "proxy",
                    "server": u.hostname,
                    "server_port": u.port or 443,
                    "uuid": u.username,
                }
                flow = q.get("flow")
                if flow:
                    ob["flow"] = flow
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
                    ob["tls"] = tls
                if transport_type == "ws":
                    ob["transport"] = {
                        "type": "ws",
                        "path": q.get("path", "/"),
                        "headers": {"Host": q.get("host", sni)},
                    }
                elif transport_type == "grpc":
                    ob["transport"] = {
                        "type": "grpc",
                        "service_name": q.get("serviceName", ""),
                    }
                return ob, [bypass_rule(u.hostname)]


            def parse_wireguard(cfg_text):
                section = None
                interface = {}
                peers = []
                cur = None
                for line in cfg_text.splitlines():
                    line = line.split("#", 1)[0].strip()
                    if not line:
                        continue
                    if line.startswith("[") and line.endswith("]"):
                        section = line[1:-1].strip().lower()
                        if section == "peer":
                            cur = {}
                            peers.append(cur)
                        continue
                    if "=" not in line:
                        continue
                    key, _, val = line.partition("=")
                    key = key.strip().lower()
                    val = val.strip()
                    if section == "interface":
                        interface[key] = val
                    elif section == "peer" and cur is not None:
                        cur[key] = val

                if "privatekey" not in interface:
                    sys.exit("wireguard config: missing [Interface] PrivateKey")
                if not peers:
                    sys.exit("wireguard config: no [Peer] section")
                addresses = [
                    a.strip() for a in interface.get("address", "").split(",") if a.strip()
                ]
                if not addresses:
                    sys.exit("wireguard config: missing [Interface] Address")

                endpoint = {
                    "type": "wireguard",
                    "tag": "proxy",
                    "system": False,
                    "address": addresses,
                    "private_key": interface["privatekey"],
                }
                if interface.get("mtu"):
                    endpoint["mtu"] = int(interface["mtu"])

                wg_peers = []
                bypass = []
                for p in peers:
                    ep = p.get("endpoint", "")
                    host, sep, port = ep.rpartition(":")
                    if not sep:
                        sys.exit(f"wireguard peer: bad Endpoint {ep!r}")
                    host = host.strip().strip("[]")
                    peer_obj = {
                        "address": host,
                        "port": int(port),
                        "public_key": p["publickey"],
                        "allowed_ips": [
                            a.strip()
                            for a in p.get("allowedips", "0.0.0.0/0, ::/0").split(",")
                            if a.strip()
                        ],
                    }
                    if p.get("presharedkey"):
                        peer_obj["pre_shared_key"] = p["presharedkey"]
                    if p.get("persistentkeepalive"):
                        peer_obj["persistent_keepalive_interval"] = int(
                            p["persistentkeepalive"]
                        )
                    wg_peers.append(peer_obj)
                    bypass.append(bypass_rule(host))
                endpoint["peers"] = wg_peers
                return endpoint, bypass


            if text.startswith("vless://"):
                proxy_outbound, server_bypass = parse_vless(text)
            elif "[interface]" in text.lower():
                proxy_endpoint, server_bypass = parse_wireguard(text)
            else:
                sys.exit("unsupported upstream: expected a vless:// URL or a WireGuard config")

            outbounds = [{"type": "direct", "tag": "direct", "routing_mark": 100}]
            if proxy_outbound is not None:
                outbounds.insert(0, proxy_outbound)

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
                "outbounds": outbounds,
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
            if proxy_endpoint is not None:
                cfg["endpoints"] = [proxy_endpoint]

            json.dump(cfg, sys.stdout, indent=2)
          '';
      # Resolve the runtime-selected config source ($1 = systemd instance %I):
      # an absolute path is used as-is, anything else is a sops secret name.
      prepareScript = pkgs.writeShellScript "singbox-ru-prepare" ''
        src="$1"
        case "$src" in
          /*) ;;
          *) src="/run/secrets/$src" ;;
        esac
        if [ ! -r "$src" ]; then
          echo "singbox-ru: config source not readable: $src" >&2
          exit 1
        fi
        ${pkgs.python3}/bin/python3 ${parserScript} < "$src" > /run/singbox-ru/config.json
        chmod 600 /run/singbox-ru/config.json
      '';
    in
    {
      # Both secret modules are cheap (just sops.secrets declarations); import
      # both so either upstream can be selected at runtime without rebuilding.
      imports = [
        nixosMods.unblock-vless-secret
        nixosMods.unblock-wg-secrets
      ];

      # Templated unit — the instance (%I) picks the config source at start:
      #   singbox-ru@<secret-name>   -> /run/secrets/<secret-name>
      #   singbox-ru@<escaped-path>  -> that file (systemd-escape'd absolute path)
      # The parser auto-detects VLESS vs WireGuard, so one template serves both.
      systemd.services."singbox-ru@" = {
        description = "sing-box transparent proxy (%I) — RU direct, rest tunnelled";
        after = [
          "network-online.target"
          "sops-nix.service"
        ];
        wants = [ "network-online.target" ];
        # No wantedBy — start manually with: sb-up [config]
        restartIfChanged = false;

        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = 5;
          RuntimeDirectory = "singbox-ru";
          RuntimeDirectoryMode = "0700";

          # %I is expanded by systemd in the directive value and passed as $1
          # (specifiers are not substituted inside the referenced script body).
          ExecStartPre = "${prepareScript} %I";

          ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /run/singbox-ru/config.json";

          ExecStopPost = pkgs.writeShellScript "singbox-ru-cleanup" ''
            rm -f /run/singbox-ru/config.json
          '';
        };
      };
    };

  flake.modules.homeManager.singbox-ru =
    { config, pkgs, ... }:
    let
      # Default config for a bare `sb-up`, from settings.singboxRuUpstream.
      defaultCfg =
        if config.settings.singboxRuUpstream == "wireguard" then
          config.settings.wireguardConfigName
        else
          "vless-chumakov";
      escape = "${pkgs.systemd}/bin/systemd-escape";
    in
    {
      # ── Usage ────────────────────────────────────────────────────────────
      # Transparent proxy: RU (geoip-ru + geosite-ru) stays direct, everything
      # else goes through the chosen upstream. The upstream is picked at RUNTIME
      # (vopono-style) — no rebuild needed to switch configs.
      #
      #   sb-up                       # default upstream (settings.singboxRuUpstream)
      #   sb-up wireguard-desktop-home  # a sops secret name -> /run/secrets/<name>
      #   sb-up vless-chumakov          # VLESS secret (VLESS vs WG auto-detected)
      #   sb-file /path/to/any.conf     # an arbitrary config file (not in sops)
      #
      #   sb-status                   # is it up? which instance?
      #   sb-config                   # dump the generated /run/singbox-ru/config.json
      #   sb-logs [cfg]               # follow the journal
      #   sb-restart [cfg]            # re-apply / swap upstream
      #   sb-down                     # stop the tunnel
      #
      # Notes:
      #   • Only one system-wide TUN at a time — sb-up drops any running instance.
      #   • Plain WireGuard only; AmneziaWG configs won't work (use vopono/awg).
      #   • Don't combine with a full-tunnel wg-full-up / vopono.
      # ─────────────────────────────────────────────────────────────────────
      programs.zsh.shellAliases = {
        # Only one system-wide TUN runs at a time, so down/status/config are
        # instance-agnostic.
        sb-down = "sudo systemctl stop 'singbox-ru@*.service'";
        sb-status = "systemctl status 'singbox-ru@*.service'";
        sb-config = "sudo cat /run/singbox-ru/config.json";
      };

      programs.zsh.initContent = ''
        # Runtime config selection, in the spirit of vopono --custom:
        #   sb-up                 -> default upstream (${defaultCfg})
        #   sb-up <secret-name>   -> /run/secrets/<secret-name>  (e.g. sb-up wireguard-desktop-home)
        #   sb-up /abs/path.conf  -> that file directly (also: sb-file <path>)
        # VLESS vs WireGuard is auto-detected from the config contents.
        # Always systemd-escape: %I un-escapes it back (turning "-" into "/"),
        # so an un-escaped name like foo-bar would wrongly become foo/bar.
        _sb_instance() { ${escape} -- "$1"; }
        sb-up() {
          local cfg="''${1:-${defaultCfg}}"
          local inst; inst="$(_sb_instance "$cfg")"
          # Drop any running instance first to keep a single active TUN.
          sudo sh -c "systemctl stop 'singbox-ru@*.service' 2>/dev/null; \
            systemctl start 'singbox-ru@$inst.service'"
        }
        sb-file() { sb-up "$1"; }
        sb-restart() { sb-up "''${1:-${defaultCfg}}"; }
        sb-logs() {
          local cfg="''${1:-${defaultCfg}}"
          journalctl -u "singbox-ru@$(_sb_instance "$cfg").service" -f
        }
      '';
    };
}
