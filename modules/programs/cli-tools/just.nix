{ ... }:
{
  flake.modules.nixos.just =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.just ];
    };
}
