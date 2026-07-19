{ ... }:
{
  flake.modules.nixos.unzip =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.unzip ];
    };
}
