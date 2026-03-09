{ inputs, ... }:
{
  flake.modules.nixos.wireproxy =
    { config, pkgs, ... }:
    {
      sops.secrets.wireguard = {
        sopsFile = inputs.self + "/secrets/wireguard.conf";
        format = "binary";
      };

      environment.systemPackages = with pkgs; [
        wireproxy
        proxychains-ng
      ];

      environment.etc."proxychains.conf".text = ''
        strict_chain
        proxy_dns
        [ProxyList]
        socks5 127.0.0.1 1080
      '';

      systemd.services.wireproxy = {
        description = "WireProxy SOCKS5 tunnel";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = 5;
          RuntimeDirectory = "wireproxy";
          RuntimeDirectoryMode = "0700";

          ExecStartPre = pkgs.writeShellScript "wireproxy-prepare" ''
                        cat > /run/wireproxy/wireproxy.conf << EOF
            WGConfig = ${config.sops.secrets.wireguard.path}

            [Socks5]
            BindAddress = 127.0.0.1:1080
            EOF
                        chmod 600 /run/wireproxy/wireproxy.conf
          '';

          ExecStart = "${pkgs.wireproxy}/bin/wireproxy -c /run/wireproxy/wireproxy.conf";

          ExecStopPost = pkgs.writeShellScript "wireproxy-cleanup" ''
            rm -f /run/wireproxy/wireproxy.conf
          '';
        };
      };
    };

  flake.modules.homeManager.wireproxy =
    { ... }:
    {
      programs.zsh.shellAliases = {
        wpu = "sudo systemctl start wireproxy.service";
        wpd = "sudo systemctl stop wireproxy.service";
        wps = "systemctl status wireproxy.service";
        proxied = "proxychains4 -q";
      };
    };
}
