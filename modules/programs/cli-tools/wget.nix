{ ... }:
{
  flake.modules.nixos.wget =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.wget ];
    };
}
