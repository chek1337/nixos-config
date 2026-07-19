{ ... }:
{
  flake.modules.nixos.nix-inspect =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.nix-inspect ];
    };
}
