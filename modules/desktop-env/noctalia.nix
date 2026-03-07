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
            animationSpeed = 0.5;
          };
          bar = {
            outerCorners = false;
            hideOnOverview = true;
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
