{ ... }:
{
  flake.modules.nixos.nvd =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.nvd ];
    };
}
