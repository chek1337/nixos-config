{
  # Режим 1: весь трафик через VPN (wg-quick)
  flake.modules.nixos.wireguard-wg-quick =
    { config, pkgs, ... }:
    let
      wgName = config.settings.wireguardConfigName;
    in
    {
      networking.wg-quick.interfaces.wg0 = {
        configFile = config.sops.secrets.${wgName}.path;
        autostart = false;
      };

      security.sudo.extraRules = [
        {
          users = [ config.settings.username ];
          commands = [
            {
              command = "${pkgs.wireguard-tools}/bin/wg-quick";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
          ];
        }
      ];
    };

  flake.modules.homeManager.wireguard-wg-quick =
    { ... }:
    {
      programs.zsh.shellAliases = {
        wg-full-up = "sudo systemctl start wg-quick-wg0.service";
        wg-full-down = "sudo systemctl stop wg-quick-wg0.service";
        wg-full-status = "sudo systemctl status wg-quick-wg0.service";
        wg-full-restart = "sudo systemctl restart wg-quick-wg0.service";
      };

      programs.zsh.initContent = ''
        wg-full-file-up() {
          sudo wg-quick up "$1"
        }
        wg-full-file-down() {
          sudo wg-quick down "$1"
        }
      '';
    };
}
