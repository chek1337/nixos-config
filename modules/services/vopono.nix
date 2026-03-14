{ inputs, ... }:
{
  flake.modules.nixos.vopono =
    { config, pkgs, ... }:
    {
      sops.secrets.wireguard = {
        sopsFile = inputs.self + "/secrets/wireguard.conf";
        format = "binary";
        # Демон vopono запускается от root, доступ есть по умолчанию
      };

      environment.systemPackages = with pkgs; [
        vopono
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
    { ... }:
    {
      # vopono будет читать этот конфиг и использовать wireguard-секрет по умолчанию
      xdg.configFile."vopono/config.toml".text = ''
        provider = "custom"
        protocol = "Wireguard"
        custom = "/run/secrets/wireguard"
      '';

      programs.zsh.shellAliases = {
        vpu = "sudo systemctl start vopono.service";
        vpd = "sudo systemctl stop vopono.service";
        vps = "systemctl status vopono.service";
        # Использование: vpx firefox, vpx transmission-gtk, итд.
        vpx = "vopono exec";
      };
    };
}
