{ inputs, ... }:
{
  flake.modules.homeManager.zen =
    { config, ... }:
    {
      imports = [ inputs.zen-browser.homeModules.beta ];

      programs.zen-browser = {
        enable = true;
        policies = config.firefoxCommon.policies // {
          DisableAppUpdate = true;
        };
        profiles.default = {
          isDefault = true;
          extensions.packages = config.firefoxCommon.extensions;
          settings = config.firefoxCommon.settings;
        };
      };

      stylix.targets.zen-browser = {
        enable = true;
        profileNames = [ "default" ];
      };

    };
}
