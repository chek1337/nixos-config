{ ... }:
{
  flake.modules.nixos.niri =
    { ... }:
    {
      programs.niri.enable = true;
      security.polkit.enable = true;
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "niri-session";
          user = "chek";
        };
      };
    };
}
