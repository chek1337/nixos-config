{ ... }:
{
  flake.modules.nixos.jq =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.jq ];
    };
}
