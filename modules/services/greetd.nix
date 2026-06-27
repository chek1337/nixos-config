{
  flake.modules.nixos.greetd =
    { pkgs, ... }:
    {
      # Логин-экран при загрузке: tuigreet спрашивает пароль (PAM),
      # и только после аутентификации запускает niri-session от имени
      # вошедшего пользователя. Сам greeter крутится под юзером `greeter`.
      #
      # Система живёт на ru_RU.UTF-8 (i18n.defaultLocale), и PAM-сессия
      # greeter'а наследует этот LANG из /etc/locale.conf, перебивая любой
      # environment.LANG у сервиса. Поэтому жёстко задаём английскую локаль
      # прямо в команде: LC_ALL имеет высший приоритет над LANG, а LANGUAGE
      # управляет выбором перевода в gettext.
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "env LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US:en ${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --cmd niri-session";
          user = "greeter";
        };
      };
    };
}
