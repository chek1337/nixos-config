{ ... }:
{
  flake.modules.nixos.atool =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.atool ];
    };
}
