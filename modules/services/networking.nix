{ config, ... }:
let
  flakeConfig = config;
in
{
  flake.modules.nixos.networking =
    { config, ... }:
    let
      username = config.settings.username;
    in
    {
      imports = with flakeConfig.flake.modules.nixos; [
        wireguard
        wireproxy
        zapret
        vopono
      ];

      networking.networkmanager.enable = true;
      users.users.${username}.extraGroups = [ "networkmanager" ];
    };

  flake.modules.homeManager.networking = {
    imports = with flakeConfig.flake.modules.homeManager; [
      wireguard
      wireproxy
      zapret
      vopono
    ];
  };
}
