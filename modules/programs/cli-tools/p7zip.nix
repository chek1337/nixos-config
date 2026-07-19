{ ... }:
{
  flake.modules.nixos.p7zip =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.p7zip ];
    };
}
