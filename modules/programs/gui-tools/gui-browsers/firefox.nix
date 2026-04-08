{
  flake.modules.homeManager.firefox =
    { lib, config, ... }:
    {
      stylix.targets.firefox.profileNames = [ "default" ]; # not working

      home.sessionVariables.DEFAULT_BROWSER = lib.getExe config.programs.firefox.package;

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
