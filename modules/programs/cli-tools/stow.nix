{ ... }:
{
  flake.modules.nixos.stow =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.stow ];
    };
}
