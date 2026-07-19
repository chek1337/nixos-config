{ ... }:
{
  flake.modules.nixos.tcpdump =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.tcpdump ];
    };
}
