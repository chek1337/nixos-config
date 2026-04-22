{
  flake.modules.homeManager.xdg-defaults =
    { ... }:
    {
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        TERMINAL = "kitty";
        BROWSER = "qutebrowser";
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          # Browser
          "text/html" = "org.qutebrowser.qutebrowser.desktop";
          "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
          "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";

          # Mail
          "x-scheme-handler/mailto" = "thunderbird.desktop";
          "message/rfc822" = "thunderbird.desktop";

          # Files
          "inode/directory" = "org.gnome.Nautilus.desktop";

          # Images
          "image/png" = "imv-dir.desktop";
          "image/jpeg" = "imv-dir.desktop";
          "image/gif" = "imv-dir.desktop";
          "image/webp" = "imv-dir.desktop";
          "image/bmp" = "imv-dir.desktop";
          "image/tiff" = "imv-dir.desktop";

          # Video / Audio
          "audio/*" = "mpv.desktop";
          "video/*" = "mpv.desktop";

          # Documents
          "application/pdf" = "org.pwmt.zathura.desktop";

          # Text
          "text/plain" = "nvim-terminal.desktop";

          # Office — Writer
          "application/vnd.oasis.opendocument.text" = "writer.desktop";
          "application/msword" = "writer.desktop";
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";

          # Office — Calc
          "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
          "application/vnd.ms-excel" = "calc.desktop";
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";

          # Office — Impress
          "application/vnd.oasis.opendocument.presentation" = "impress.desktop";
          "application/vnd.ms-powerpoint" = "impress.desktop";
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "impress.desktop";
        };
      };
    };
}
