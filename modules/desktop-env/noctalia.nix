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
          general.language = "ru";
          notifications = {
            enableKeyboardLayoutToast = false;
          };
        };
      };
    };
}
