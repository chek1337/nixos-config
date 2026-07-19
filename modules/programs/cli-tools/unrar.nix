{ ... }:
{
  flake.modules.nixos.unrar =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.unrar ];
    };
}
