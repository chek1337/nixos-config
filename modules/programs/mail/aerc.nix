{ ... }:
{
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

      accounts.email.accounts."YA-daniplay" = {
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
      accounts.email.accounts."YA-loychenko" = {
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
}
