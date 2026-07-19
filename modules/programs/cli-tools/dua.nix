{ ... }:
{
  flake.modules.nixos.dua =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.dua ];
    };
}
