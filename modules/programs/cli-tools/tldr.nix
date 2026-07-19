{ ... }:
{
  flake.modules.nixos.tldr =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.tldr ];
    };
}
