{ ... }:
{
  flake.modules.nixos.nh =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.nh ];
    };
}
