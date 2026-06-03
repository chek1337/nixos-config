{ inputs, lib, ... }:
{
  flake.modules.nixos.unblock-wg-secrets =
    { config, ... }:
    let
      names = [
        config.settings.wireguardConfigName
      ]
      ++ config.settings.wireguardExtraConfigs
      ++ config.settings.amneziaWgExtraConfigs;
    in
    {
      sops.secrets = lib.listToAttrs (
        map (name: {
          inherit name;
          value = {
            sopsFile = inputs.self + "/secrets/${name}.conf";
            format = "binary";
          };
        }) names
      );
    };

  flake.modules.nixos.unblock-vless-secret =
    { config, ... }:
    {
      sops.secrets."vless-chumakov" = {
        sopsFile = inputs.self + "/secrets/secrets.yaml";
        key = "vless-chumakov";
        owner = config.settings.username;
      };
    };
}
