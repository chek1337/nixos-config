{
  # Режим 1: весь трафик через VPN (wg-quick)
  flake.modules.nixos.wireguard-wg-quick =
    { config, ... }:
    let
      wgName = config.settings.wireguardConfigName;
    in
    {
      networking.wg-quick.interfaces.wg0 = {
        configFile = config.sops.secrets.${wgName}.path;
        autostart = false;
      };
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
    };
}
