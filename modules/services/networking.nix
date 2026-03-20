{ config, ... }:
{
  flake.modules.nixos.networking = {
    imports = with config.flake.modules.nixos; [
      wireguard
      wireproxy
      zapret
      vopono
    ];

    networking.networkmanager.enable = true;
  };

  flake.modules.homeManager.networking = {
    imports = with config.flake.modules.homeManager; [
      wireguard
      wireproxy
      zapret
      vopono
    ];
  };
}
