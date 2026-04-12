{
  flake.modules.nixos.zoom =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.zoom-us ];
    };

  flake.modules.homeManager.zoom =
    { pkgs, config, ... }:
    {
      xdg.desktopEntries.zoom = {
        name = "Zoom";
        genericName = "Video Conferencing";
        exec = "env XDG_SESSION_TYPE=wayland zoom %U";
        icon = "Zoom";
        categories = [
          "Network"
          "InstantMessaging"
        ];
        mimeType = [
          "x-scheme-handler/zoommtg"
          "x-scheme-handler/zoomus"
          "x-scheme-handler/zoom"
        ];
        startupNotify = true;
      };
    };
}
