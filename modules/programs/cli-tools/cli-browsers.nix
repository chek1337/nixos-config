{ config, ... }:
{
  flake.modules.homeManager.cli-browsers = {
    imports = with config.flake.modules.homeManager; [
      # browsh
      # firefox
      w3m
    ];
  };
}
