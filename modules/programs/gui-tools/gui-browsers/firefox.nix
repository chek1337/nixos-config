{
  flake.modules.homeManager.firefox =
    { config, ... }:
    {
      stylix.targets.firefox.profileNames = [ "default" ]; # not working

      programs.firefox = {
        enable = true;
        policies = config.firefoxCommon.policies;
        profiles.default = {
          name = "default";
          extensions.packages = config.firefoxCommon.extensions;
          settings = config.firefoxCommon.settings;
        };
      };
    };
}
