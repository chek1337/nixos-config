{
  flake.modules.homeManager.thunderbird =
    { ... }:
    {
      programs.thunderbird = {
        enable = true;
        profiles."default" = {
          isDefault = true;
        };
      };

      accounts.email.accounts."YA-daniplay".thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };
      accounts.email.accounts."YA-loychenko".thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };

      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/mailto" = "thunderbird.desktop";
        "message/rfc822" = "thunderbird.desktop";
      };
    };
}
