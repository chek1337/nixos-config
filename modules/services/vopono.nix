{ inputs, ... }:
{
  flake.modules.nixos.vopono =
    { config, pkgs, ... }:
    let
      wgName = config.settings.wireguardConfigName;
    in
    {
      sops.secrets.${wgName} = {
        sopsFile = inputs.self + "/secrets/${wgName}.conf";
        format = "binary";
      };

      environment.systemPackages = with pkgs; [
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
          ExecStart = "${pkgs.vopono}/bin/vopono daemon";
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
      ...
    }:
    let
      wgName = config.settings.wireguardConfigName;
    in
    {
      programs.zsh.shellAliases = {
        vopono-up = "sudo systemctl start vopono.service";
        vopono-down = "sudo systemctl stop vopono.service";
        vopono-status = "sudo systemctl status vopono.service";
        vopono-restart = "sudo systemctl restart vopono.service";
        vopono-exec = "vopono exec --custom /run/secrets/${wgName} --protocol wireguard";
      };
      xdg.desktopEntries = {
        qutebrowser-vpn = {
          name = "qutebrowser (VPN)";
          exec = "${pkgs.vopono}/bin/vopono exec --protocol wireguard --custom /run/secrets/${wgName} ${pkgs.qutebrowser}/bin/qutebrowser %U";
          icon = "qutebrowser";
          comment = "qutebrowser via Vopono WireGuard";
          categories = [
            "Network"
            "WebBrowser"
          ];
          terminal = true;
        };
      };
    };
}
