{ ... }:
{
  flake.modules.nixos.playerctl =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.playerctl ];
    };
}
