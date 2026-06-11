{ ... }:
{
  flake.modules.nixos.anydesk =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.anydesk ];
    };
}
