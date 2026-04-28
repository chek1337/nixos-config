{
  flake.modules.homeManager.niri-window-rules =
    { config, lib, ... }:
    let
      baseRules = [
        ''
          window-rule {
              match app-id=r#"firefox$"# title="^Picture-in-Picture$"
              open-floating true
          }
        ''
        ''
          window-rule {
              match app-id="qutebrowser" at-startup=true
              open-on-workspace "1"
              open-maximized true
          }
        ''
        ''
          window-rule {
              match app-id=r"(?i)ayugram"
              open-on-workspace "4"
              open-maximized true
          }
        ''
        ''
          window-rule {
              match app-id="thunderbird" at-startup=true
              open-on-workspace "5"
              open-maximized true
          }
        ''
        ''
          window-rule {
              match app-id="spotify" at-startup=true
              open-on-workspace "6"
              open-maximized true
          }
        ''
        ''
          window-rule {
              match app-id="satty"
              open-floating true
          }
        ''
        ''
          window-rule {
              match app-id="mpv-mini"
              open-floating true
              default-column-width { fixed 320; }
              default-window-height { fixed 180; }
              default-floating-position relative-to="top-right" x=8 y=8
          }
        ''
        # open-pinned true
      ];
    in
    {
      config.services.niri._kdl.windowRules = lib.concatStringsSep "\n" (
        baseRules ++ config.services.niri.windowRules
      );
    };
}
