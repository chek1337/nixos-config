{ inputs, ... }:
{
  flake.modules.nixos.vopono =
    { config, pkgs, ... }:
    {
      sops.secrets.wireguard = {
        sopsFile = inputs.self + "/secrets/wireguard.conf";
        format = "binary";
      };
      environment.systemPackages = with pkgs; [
        vopono
        wireguard-tools
      ];
      security.sudo.extraRules = [
        {
          users = [ "wheel" ];
          commands = [
            {
              command = "${pkgs.vopono}/bin/vopono *";
              options = [ "NOPASSWD" ];
            }
            # {
            #   command = "/run/current-system/sw/bin/systemctl start vopono.service";
            #   options = [ "NOPASSWD" ];
            # }
            # {
            #   command = "/run/current-system/sw/bin/systemctl stop vopono.service";
            #   options = [ "NOPASSWD" ];
            # }
            # {
            #   command = "/run/current-system/sw/bin/systemctl status vopono.service";
            #   options = [ "NOPASSWD" ];
            # }
          ];
        }
      ];
      systemd.services.vopono = {
        description = "Vopono root daemon";
        after = [ "network.target" ];
        requires = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.vopono}/bin/vopono daemon";
          Restart = "on-failure";
          RestartSec = "2s";
          Environment = "RUST_LOG=info";
        };
      };
    };
  flake.modules.homeManager.vopono =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [ qutebrowser ];
      programs.zsh.shellAliases = {
        vopono-up = "sudo systemctl start vopono.service";
        vopono-down = "sudo systemctl stop vopono.service";
        vopono-status = "sudo systemctl status vopono.service";
        vopono-exec = "vopono exec --custom /run/secrets/wireguard --protocol wireguard";
      };
      xdg.desktopEntries = {
        qutebrowser-vpn = {
          name = "Qutebrowser (VPN)";
          exec = "${pkgs.vopono}/bin/vopono exec --protocol wireguard --custom /run/secrets/wireguard ${pkgs.qutebrowser}/bin/qutebrowser %U";
          icon = "qutebrowser";
          comment = "Qutebrowser via Vopono WireGuard";
          categories = [
            "Network"
            "WebBrowser"
          ];
          terminal = false;
        };
      };
    };
}
