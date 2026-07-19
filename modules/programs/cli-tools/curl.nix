{ ... }:
{
  flake.modules.nixos.curl =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.curl ];
    };
}
