{ inputs, ... }:
{
  flake.modules.nixos.wireguard =
    { config, ... }:
    {
      sops.secrets.wireguard = {
        sopsFile = inputs.self + "/secrets/wireguard.conf";
        format = "binary";
      };

      networking.firewall.checkReversePath = "loose";

      networking.wg-quick.interfaces.wg0 = {
        configFile = config.sops.secrets.wireguard.path;
        autostart = false;
      };
    };

  flake.modules.homeManager.wireguard =
    { ... }:
    {
      programs.zsh.shellAliases = {
        wgu = "sudo systemctl start wg-quick-wg0.service";
        wgd = "sudo systemctl stop wg-quick-wg0.service";
      };
    };
}
