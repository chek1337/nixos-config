{ ... }:
{
  flake.modules.nixos.wine =
    { pkgs-stable, ... }:
    {
      environment.systemPackages = with pkgs-stable; [
        wineWow64Packages.stable
        winetricks
      ];
    };
}
