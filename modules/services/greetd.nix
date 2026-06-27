{
  flake.modules.nixos.greetd =
    { pkgs, ... }:
    {
      # Логин-экран при загрузке: tuigreet спрашивает пароль (PAM),
      # и только после аутентификации запускает niri-session от имени
      # вошедшего пользователя. Сам greeter крутится под юзером `greeter`.
      systemd.services.greetd.environment.LANG = "ru_RU.UTF-8";

      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --cmd niri-session";
          user = "greeter";
        };
      };
    };
}
