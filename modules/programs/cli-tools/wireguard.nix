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
      };
    };
}
