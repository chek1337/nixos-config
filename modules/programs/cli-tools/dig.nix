{ ... }:
{
  flake.modules.nixos.dig =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.dig ];
    };
}
