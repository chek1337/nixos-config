{ ... }:
{
  flake.modules.nixos.fzf =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.fzf ];
    };
}
