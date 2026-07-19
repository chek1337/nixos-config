{ ... }:
{
  flake.modules.nixos.nixfmt =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.nixfmt ];
    };
}
