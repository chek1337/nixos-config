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
    let
      defaultAercConfig = {
        aerc = {
          enable = true;
          extraAccounts = {
            default = "INBOX";
            check-mail = "5m";
            check-mail-cmd = "${pkgs.isync}/bin/mbsync --all";
            check-mail-timeout = "15s";
          };
        };
      };
    in
    {
      home.packages = with pkgs; [
        bat
        catdoc
        pandoc
        delta
        gawk
        imv
        mpv
        odt2txt
        w3m
        xlsx2csv
        zathura
      ];

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
            pager = "${pkgs.less}/bin/less -R";
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
            "text/plain" =
              "${pkgs.aerc}/libexec/aerc/filters/wrap -w 100 | ${pkgs.aerc}/libexec/aerc/filters/colorize";
            "text/calendar" =
              "${pkgs.gawk}/bin/awk --file ${pkgs.aerc}/libexec/aerc/filters/calendar | ${pkgs.aerc}/libexec/aerc/filters/colorize";
            "text/html" =
              "${pkgs.aerc}/libexec/aerc/filters/html-unsafe | ${pkgs.aerc}/libexec/aerc/filters/colorize";
            "message/delivery-status" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
            "message/rfc822" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
            ".headers" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
            "subject,~^\\[PATCH" = "${pkgs.delta}/bin/delta --color-only";
            "application/x-sh" = "${pkgs.bat}/bin/bat --force-colorization --paging=never --language sh";
            "application/pdf" = "${pkgs.zathura}/bin/zathura -";
            "audio/*" = "${pkgs.mpv}/bin/mpv -";
            "image/*" = "${pkgs.imv}/bin/imv -";
            "application/msword" = "${pkgs.catdoc}/bin/catdoc -";
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
              "${pkgs.pandoc}/bin/pandoc -f docx -t plain";
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
              "${pkgs.xlsx2csv}/bin/xlsx2csv -";
            "application/vnd.ms-excel" = "${pkgs.catdoc}/bin/xls2csv -";
            "application/vnd.oasis.opendocument.text" = "${pkgs.odt2txt}/bin/odt2txt --subst=all -";
          };
        };
      };

      accounts.email = {
        maildirBasePath = ".maildir";
        accounts."YA-daniplay" = defaultAercConfig // {
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
          folders = {
            inbox = "INBOX";
            drafts = "Черновики";
            sent = "Отправленные";
            trash = "Удаленные";
          };
        };
        accounts."YA-loychenko" = defaultAercConfig // {
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
