{
  flake.modules.nixos.greetd =
    { config, ... }:
    {
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "niri-session";
          user = config.settings.username;
        };
      };
    };
}
