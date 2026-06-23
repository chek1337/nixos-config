{
  flake.modules.nixos.greetd =
    { pkgs, ... }:
    {
      # Логин-экран при загрузке: tuigreet спрашивает пароль (PAM),
      # и только после аутентификации запускает niri-session от имени
      # вошедшего пользователя. Сам greeter крутится под юзером `greeter`.
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --cmd niri-session";
          user = "greeter";
        };
      };
    };
}
