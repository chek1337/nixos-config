{
  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    let
      yaziLauncher = pkgs.writeShellScript "yazi-launcher" ''
        exec kitty -e zsh -ic "y; exec zsh"
      '';
    in
    {
      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        shellWrapperName = "y";

        settings = {
          mgr = {
            ratio = [
              1
              2
              4
            ];
          };

          opener = {
            play = [
              {
                run = ''mpv --force-window "$@"'';
                orphan = true;
                for = "unix";
              }
            ];
            image = [
              {
                run = ''imv "$@"'';
                orphan = true;
                for = "unix";
              }
            ];
          };

          open = {
            rules = [
              {
                mime = "audio/*";
                use = "play";
              }
              {
                mime = "video/*";
                use = "play";
              }
              {
                mime = "image/*";
                use = "image";
              }
            ];
          };
        };
      };

      xdg.desktopEntries.yazi = {
        name = "Yazi";
        icon = "yazi";
        comment = "Terminal file manager";
        exec = "${yaziLauncher}";
        terminal = false;
        type = "Application";
        mimeType = [ "inode/directory" ];
        categories = [
          "Utility"
          "FileManager"
          "ConsoleOnly"
        ];
      };
    };
}
