{ ... }:
{
  flake.modules.nixos.bottles =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.bottles ];
    };
}
