{ inputs, ... }:
{
  flake.modules.nixos.vopono =
    { config, pkgs-stable, ... }:
    let
      wgName = config.settings.wireguardConfigName;
    in
    {
      sops.secrets.${wgName} = {
        sopsFile = inputs.self + "/secrets/${wgName}.conf";
        format = "binary";
      };

      security.sudo.extraRules = [
        {
          users = [ config.settings.username ];
          commands = [
            {
              command = "${pkgs-stable.vopono}/bin/vopono";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
          ];
        }
      ];

      environment.systemPackages = with pkgs-stable; [
        vopono
        wireguard-tools
      ];

      systemd.services.vopono = {
        description = "Vopono root daemon";
        after = [ "network.target" ];
        requires = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs-stable.vopono}/bin/vopono daemon";
          Restart = "on-failure";
          RestartSec = "2s";
          Environment = "RUST_LOG=info";
        };
      };
    };

  flake.modules.homeManager.vopono =
    {
      config,
      pkgs,
      pkgs-stable,
      ...
    }:
    let
      wgName = config.settings.wireguardConfigName;
      wgSecret = "/run/secrets/${wgName}";
      vopono = "${pkgs-stable.vopono}/bin/vopono";
      voponoVpnApps = pkgs.writeShellScript "vopono-vpn-apps" ''
        for i in $(seq 1 30); do
          [ -f ${wgSecret} ] && ${pkgs-stable.systemd}/bin/systemctl is-active --quiet vopono.service && break
          sleep 1
        done
        ${vopono} exec --protocol wireguard --custom ${wgSecret} ${pkgs-stable.qutebrowser}/bin/qutebrowser &
        sleep 3
        ${vopono} exec --protocol wireguard --custom ${wgSecret} ${pkgs-stable.ayugram-desktop}/bin/AyuGram &
        wait
      '';
    in
    {
      services.niri.spawnAtStartup = [ "${voponoVpnApps}" ];

      programs.zsh.shellAliases = {
        vopono-up = "sudo systemctl start vopono.service";
        vopono-down = "sudo systemctl stop vopono.service";
        vopono-status = "sudo systemctl status vopono.service";
        vopono-restart = "sudo systemctl restart vopono.service";
        vopono-exec = "vopono exec --custom /run/secrets/${wgName} --protocol wireguard";
      };
      # VPN desktop entries replaced by noctalia custom-commands plugin
      # xdg.desktopEntries = {
      #   qutebrowser-vpn = {
      #     name = "qutebrowser (VPN)";
      #     exec = "${pkgs.vopono}/bin/vopono exec --protocol wireguard --custom /run/secrets/${wgName} ${pkgs.qutebrowser}/bin/qutebrowser %U";
      #     icon = "qutebrowser";
      #     comment = "qutebrowser via Vopono WireGuard";
      #     categories = [
      #       "Network"
      #       "WebBrowser"
      #     ];
      #     terminal = false;
      #   };
      #   telegram-desktop-vpn = {
      #     name = "Telegram (VPN)";
      #     exec = "${pkgs.vopono}/bin/vopono exec --protocol wireguard --custom /run/secrets/${wgName} ${pkgs.telegram-desktop}/bin/Telegram -- %u";
      #     icon = "telegram";
      #     comment = "Telegram Desktop via Vopono WireGuard";
      #     categories = [
      #       "Network"
      #       "InstantMessaging"
      #     ];
      #     terminal = false;
      #   };
      # };
    };
}
