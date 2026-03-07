{ inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    { ... }:
    {
      imports = [ inputs.noctalia.homeModules.default ];
      programs.noctalia-shell = {
        enable = true;
        systemd.enable = true;
        settings = {
          general = {
            language = "ru";
            enableShadows = false;
            # animationSpeed = 0.5;
            animationDisabled = true;
          };
          bar = {
            outerCorners = false;
            hideOnOverview = true;
            marginVertical = 0;
            marginHorizontal = 0;
          };
          notifications = {
            enableKeyboardLayoutToast = false;
          };
          colorSchemes = {
            predefinedScheme = "Nord";
          };
          location = {
            name = "Novosibirsk";
          };
        };
      };
    };
}
