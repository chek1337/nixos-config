{ ... }:
{
  flake.modules.nixos.niri =
    { pkgs, username, ... }:
    {
      programs.niri.enable = true;
      security.polkit.enable = true;
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "niri-session";
          user = username;
        };
      };
    };

  flake.modules.homeManager.niri =
    { ... }:
    {
      xdg.configFile."niri/config.kdl".source = ./config.kdl;
    };
}
