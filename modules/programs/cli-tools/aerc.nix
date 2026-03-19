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
      home.packages = [ pkgs.catimg ];

      programs.mbsync.enable = true;

      services.mbsync = {
        enable = true;
        frequency = "*:0/5";
      };

      programs.aerc = {
        enable = true;
        extraConfig = {
          general.unsafe-accounts-conf = true;
          viewer = {
            pager = "less -R";
            alternatives = "text/plain,text/html";
          };
          ui = {
            tab-title-account = "{{.Account}} {{if gt .Unread 0}}({{.Unread}}){{end}}";
            threading-enabled = true;
            mouse-enabled = true;
            new-message-bell = false;
            dirlist-delay = "200ms";
            sort = "-r date";
          };
          filters = {
            "text/plain" = "colorize";
            "text/html" = "w3m -T text/html -o display_link_number=1";
            "image/*" = "catimg -w $(tput cols) -";
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
          mbsync = {
            enable = true;
            create = "maildir";
            patterns = [ "*" ];
          };
          aerc = {
            enable = true;
            extraAccounts = {
              default = "INBOX";
              check-mail-cmd = "mbsync YA-daniplay";
              check-mail-timeout = "30s";
            };
          };
          folders = {
            inbox = "INBOX";
            drafts = "Черновики";
            sent = "Отправленные";
            trash = "Удаленные";
          };
        };
        accounts."YA-loychenko" = {
          address = "loychenko.d@yandex.ru";
          flavor = "yandex.com";
          userName = "loychenko.d@yandex.ru";
          realName = "Loychenko D.";
          passwordCommand = "${pkgs.coreutils}/bin/cat /run/secrets/loychenko-d-yandex-password";
          mbsync = {
            enable = true;
            create = "maildir";
            patterns = [ "*" ];
          };
          aerc = {
            enable = true;
            extraAccounts = {
              default = "INBOX";
              check-mail-cmd = "mbsync YA-loychenko";
              check-mail-timeout = "30s";
            };
          };
          folders = {
            inbox = "INBOX";
            drafts = "Drafts";
            sent = "Sent";
            trash = "Trash";
          };
        };
      };
    };
}
