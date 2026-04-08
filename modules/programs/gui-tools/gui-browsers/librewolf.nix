{
  flake.modules.homeManager.librewolf =
    { config, ... }:
    {
      programs.librewolf = {
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
