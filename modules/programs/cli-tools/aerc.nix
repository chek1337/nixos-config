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
    };

  flake.modules.homeManager.aerc =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.catimg ];

      programs.aerc = {
        enable = true;
        extraConfig = {
          general.unsafe-accounts-conf = true;
          viewer = {
            pager = "less -R";
            alternatives = "text/plain,text/html";
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
        accounts.daniplay1337-yandex = {
          address = "DaniPlay1337@yandex.ru";
          primary = true;
          flavor = "yandex.com";
          userName = "DaniPlay1337@yandex.ru";
          realName = "DaniPlay1337";
          passwordCommand = "${pkgs.coreutils}/bin/cat /run/secrets/daniplay1337-yandex-password";
          aerc = {
            enable = true;
          };
          folders = {
            inbox = "Inbox";
            drafts = "Drafts";
            sent = "Sent";
            trash = "Trash";
          };
        };
      };
    };
}
