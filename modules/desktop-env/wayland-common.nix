{ inputs, ... }:
{
  flake.modules.nixos.wayland-common =
    { pkgs, ... }:
    let
      # Пин satty на 0.20.1 — см. комментарий у инпута nixpkgs-satty в flake.nix.
      # В 0.21.x сломался crop (Ctrl+C копирует весь экран, а не выделение).
      pkgsSatty = import inputs.nixpkgs-satty { inherit (pkgs) system; };
    in
    {
      environment.systemPackages = with pkgs; [
        wl-clipboard
        pkgsSatty.satty
        grim
        slurp
        wayfreeze
        cliphist
      ];

      programs.xwayland.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
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
