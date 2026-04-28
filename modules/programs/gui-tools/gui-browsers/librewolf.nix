{
  flake.modules.homeManager.librewolf =
    { config, pkgs-stable, ... }:
    {
      stylix.targets.librewolf = {
        # not working
        enable = true;
        profileNames = [ "default" ];
      };

      programs.librewolf = {
        enable = true;
        package = pkgs-stable.librewolf;
        policies = config.firefoxCommon.policies;
        profiles.default = {
          name = "default";
          extensions.packages = config.firefoxCommon.extensions;
          settings = config.firefoxCommon.settings;
        };
      };
    };
}
