{ config, ... }:
{
  flake.modules.nixos.desktop-base = {
    imports = with config.flake.modules.nixos; [
      sops
      bluetooth
      power
      wayland-common
    ];
  };

  flake.modules.homeManager.desktop-base = { };
}
