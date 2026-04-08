{
  flake.modules.homeManager.librewolf =
    { config, ... }:
    {
      stylix.targets.librewolf = {
        # not working
        enable = true;
        profileNames = [ "default" ];
      };

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
