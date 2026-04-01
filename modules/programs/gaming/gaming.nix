{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "steam"
    "wine"
    "flatpak"
    "bottles"
  ];
  hmModules = [
    "lutris"
    "mangohud"
    "bottles"
    "protonup"
  ];
in
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      imports = map nixosMod modules;

      programs.gamemode.enable = true;

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 100;
      };

      boot.kernel.sysctl = {
        "vm.swappiness" = 180;
        "vm.watermark_boost_factor" = 0;
        "vm.watermark_scale_factor" = 125;
        "vm.page-cluster" = 0;
        "vm.overcommit_memory" = 1;
      };

      hardware.graphics.enable = true;
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
