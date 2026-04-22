{
  flake.modules.nixos.wayland-common =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        wl-clipboard
        satty
        grim
        slurp
        wayfreeze
        cliphist
      ];

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      security.rtkit.enable = true;
      security.polkit.enable = true;

      # xdg-desktop-portal-gnome provides the ScreenCast portal needed for
      # screen sharing in Zoom, Discord, browsers, etc. on niri/Wayland.
      # xdg-desktop-portal-gtk handles file pickers and other generic portals.
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
        config.common.default = [
          "gnome"
          "gtk"
        ];
      };
    };
}
