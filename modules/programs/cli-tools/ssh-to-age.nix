{ ... }:
{
  flake.modules.nixos.ssh-to-age =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.ssh-to-age ];
    };
}
