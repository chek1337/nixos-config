{ ... }:
{
  flake.modules.nixos.aerc =
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

  flake.modules.homeManager.aerc =
    { pkgs, ... }:
    {
      programs.mbsync.enable = true;

      programs.aerc = {
        enable = true;
        extraConfig = {
          general.unsafe-accounts-conf = true;
          viewer = {
            pager = "${pkgs.less}/bin/less -R";
            alternatives = "text/plain,text/html";
          };
          filters = {
            "text/plain" =
              "${pkgs.aerc}/libexec/aerc/filters/wrap -w 100 | ${pkgs.aerc}/libexec/aerc/filters/colorize";
            "text/html" =
              "${pkgs.aerc}/libexec/aerc/filters/html-unsafe | ${pkgs.aerc}/libexec/aerc/filters/colorize";
            "application/pdf" = "${pkgs.zathura}/bin/zathura -";
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
              "${pkgs.pandoc}/bin/pandoc -f docx -t plain";
          };
        };
      };

      accounts.email = {
        maildirBasePath = ".maildir";
        accounts."YA-daniplay" = {
          address = "DaniPlay1337@yandex.ru";
          primary = true;
          flavor = "yandex.com";
          userName = "DaniPlay1337@yandex.ru";
          realName = "DaniPlay1337";
          passwordCommand = "${pkgs.coreutils}/bin/cat /run/secrets/daniplay1337-yandex-password";
          aerc = {
            enable = true;
            extraAccounts = {
              default = "Inbox";
              check-mail = "5m";
              check-mail-cmd = "${pkgs.isync}/bin/mbsync --all";
              check-mail-timeout = "15s";
            };
          };
          mbsync = {
            enable = true;
            create = "maildir";
            patterns = [ "*" ];
          };
        };
        accounts."YA-loychenko" = {
          address = "loychenko.d@yandex.ru";
          flavor = "yandex.com";
          userName = "loychenko.d@yandex.ru";
          realName = "Loychenko D.";
          passwordCommand = "${pkgs.coreutils}/bin/cat /run/secrets/loychenko-d-yandex-password";
          aerc = {
            enable = true;
            extraAccounts = {
              default = "Inbox";
              check-mail = "5m";
              check-mail-cmd = "${pkgs.isync}/bin/mbsync --all";
              check-mail-timeout = "15s";
            };
          };
          mbsync = {
            enable = true;
            create = "maildir";
            patterns = [ "*" ];
          };
        };
      };
    };
}
