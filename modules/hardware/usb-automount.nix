{
  flake.modules.nixos.usb-automount =
    { pkgs, ... }:
    {
      services.udisks2.enable = true;

      # Support for NTFS (Windows drives)
      environment.systemPackages = [ pkgs.ntfs3g ];
    };

  flake.modules.homeManager.usb-automount =
    { ... }:
    {
      services.udiskie = {
        enable = true;
        automount = true;
        notify = true;
        tray = "never";
      };
    };
}
