{
  flake.modules.homeManager.firefox =
    { config, pkgs-stable, ... }:
    {
      stylix.targets.firefox.profileNames = [ "default" ]; # not working

      programs.firefox = {
        enable = true;
        package = pkgs-stable.firefox;
        policies = config.firefoxCommon.policies;
        profiles.default = {
          name = "default";
          extensions.packages = config.firefoxCommon.extensions;
          settings = config.firefoxCommon.settings;
        };
      };
    };
}
