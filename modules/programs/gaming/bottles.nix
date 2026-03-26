{ pkgs, ... }:
{
  flake.modules.nixos.bottles = {
    environment.systemPackages = [ pkgs.bottles ];
  };
}
