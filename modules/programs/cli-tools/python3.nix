{ ... }:
{
  flake.modules.nixos.python3 =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.python3 ];
    };
}
