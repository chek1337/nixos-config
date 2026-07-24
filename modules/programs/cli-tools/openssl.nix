{ ... }:
{
  flake.modules.nixos.openssl =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.openssl ];
    };
}
