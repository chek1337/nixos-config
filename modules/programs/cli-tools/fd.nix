{ ... }:
{
  flake.modules.nixos.fd =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.fd ];
    };
}
