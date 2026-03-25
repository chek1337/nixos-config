{ ... }:
{
  flake.modules.nixos.email-accounts =
    { config, ... }:
    let
      username = config.settings.username;
    in
    {
      sops.secrets.daniplay1337-yandex-password = {
        owner = username;
      };
      sops.secrets.loychenko-d-yandex-password = {
        owner = username;
      };
    };

  flake.modules.homeManager.email-accounts =
    { pkgs, ... }:
    {
      accounts.email = {
        maildirBasePath = ".maildir";
        accounts."YA-daniplay" = {
          address = "DaniPlay1337@yandex.ru";
          primary = true;
          flavor = "yandex.com";
          userName = "DaniPlay1337@yandex.ru";
          realName = "DaniPlay1337";
          passwordCommand = "${pkgs.coreutils}/bin/cat /run/secrets/daniplay1337-yandex-password";
        };
        accounts."YA-loychenko" = {
          address = "loychenko.d@yandex.ru";
          flavor = "yandex.com";
          userName = "loychenko.d@yandex.ru";
          realName = "Loychenko D.";
          passwordCommand = "${pkgs.coreutils}/bin/cat /run/secrets/loychenko-d-yandex-password";
        };
      };
    };
}
