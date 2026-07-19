{ ... }:
{
  flake.modules.nixos.gnumake =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.gnumake ];
    };
}
