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
            default = "Inbox";
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
            styleset-name = "nord";
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
        stylesets.nord = ''
          *.default=true
          *.normal=true

          title.bg=#5E81AC
          title.fg=#ECEFF4
          title.bold=true

          header.bold=true
          header.fg=#EBCB8B

          tab.selected.fg=#ECEFF4
          tab.selected.bg=#5E81AC
          tab.selected.bold=false
          dirlist*.selected.bg=#3B4252
          dirlist*.selected.fg=#ECEFF4
          dirlist*.selected.bold=false
          dirlist*.selected.italic=false

          *error.bold=true
          *error.fg=#BF616A
          *warning.fg=#EBCB8B
          *success.fg=#A3BE8C

          statusline_error.fg=#BF616A

          msglist_unread.fg=#ECEFF4
          msglist_unread.bold=true
          msglist_deleted.fg=#4C566A
          msglist_*.selected.bg=#3B4252
          msglist_result.bg=#5E81AC
          msglist_marked.fg=#ECEFF4
          msglist_marked.bg=#4C566A
          msglist_marked.bold=true
          msglist_marked.selected.fg=#ECEFF4
          msglist_marked.selected.bg=#4C566A
          msglist_marked.selected.bold=true
          msglist_pill.reverse=true

          part_*.fg=#ECEFF4
          part_mimetype.fg=#81A1C1
          part_*.selected.fg=#ECEFF4
          part_*.selected.bg=#3B4252
          part_filename.selected.bold=true

          completion_pill.reverse=false
          selector_focused.bold=false
          selector_focused.bg=#3B4252
          selector_focused.fg=#ECEFF4
          selector_chooser.bold=false
          selector_chooser.bg=#3B4252
          selector_chooser.fg=#ECEFF4
          default.selected.bold=false
          default.selected.fg=#ECEFF4
          default.selected.bg=#3B4252

          completion_default.selected.bg=#3B4252
          completion_default.selected.fg=#ECEFF4

          [viewer]
          *.default=true
          *.normal=true
          url.fg=#81A1C1
          header.bold=true
          signature.dim=true
          diff_meta.bold=true
          diff_chunk.dim=true
          diff_add.fg=#A3BE8C
          diff_del.fg=#BF616A
          quote_*.fg=#88C0D0
          quote_*.dim=true
          quote_1.dim=false
        '';
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
        };
      };
    };
}
