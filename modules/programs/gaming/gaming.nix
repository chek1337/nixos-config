{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "steam"
    "wine"
    "bottles"
  ];
  hmModules = [
    "lutris"
    "mangohud"
  ];
in
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      imports = map nixosMod modules;

      programs.gamemode.enable = true;

      hardware.graphics.enable32Bit = true;

      environment.systemPackages = with pkgs; [
        gamescope
        umu-launcher
        innoextract
      ];
    };

  flake.modules.homeManager.gaming = {
    imports = map hmMod hmModules;
  };
}
