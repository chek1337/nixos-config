{ ... }:
{
  flake.modules.nixos.vopono =
    {
      config,
      pkgs,
      ...
    }:
    {
      assertions = [
        {
          assertion = config.sops.secrets ? wireguard;
          message = "flake.modules.nixos.vopono требует flake.modules.nixos.wireguard (sops secret 'wireguard')";
        }
      ];

      environment.systemPackages = with pkgs; [
        vopono
      ];

      systemd.services.vopono = {
        description = "Vopono root daemon";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.vopono}/bin/vopono daemon";
          Restart = "on-failure";
          RestartSec = "2s";
          Environment = "RUST_LOG=info";
        };
      };

      security.sudo.extraRules = [
        {
          users = [ "chek" ]; # замени на своего пользователя
          commands = [
            {
              command = "${pkgs.vopono}/bin/vopono *";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };

  flake.modules.homeManager.vopono =
    { osConfig, ... }:
    let
      wgConf = osConfig.sops.secrets.wireguard.path;
      voponoBase = "vopono exec --protocol wireguard --custom ${wgConf}";
    in
    {
      programs.zsh.shellAliases = {
        vopono-up = "sudo systemctl start vopono.service";
        vopono-down = "sudo systemctl stop vopono.service";
        vopono-status = "sudo systemctl status vopono.service";
        vopono-logs = "sudo journalctl -u vopono -e";

        vopono-exec = "${voponoBase}";

        vopono-list = "vopono list namespaces";
        vopono-apps = "vopono list applications";
      };
    };
}
