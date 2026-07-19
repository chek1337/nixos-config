{ ... }:
{
  flake.modules.nixos.pciutils =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.pciutils ];
    };
}
