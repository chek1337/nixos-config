{
  flake.modules.nixos.usb-automount =
    { pkgs, ... }:
    {
      services.udisks2.enable = true;

      # Support for NTFS (Windows drives)
      environment.systemPackages = [ pkgs.ntfs3g ];
    };

  flake.modules.homeManager.usb-automount =
    { pkgs, ... }:
    let
      fileManager = pkgs.writeShellScript "udiskie-yazi" ''
        target="''${1:-$HOME}"
        [ -d "$target" ] || target="$HOME"
        exec ${pkgs.kitty}/bin/kitty --directory "$target" \
          ${pkgs.zsh}/bin/zsh -i -c 'y; exec ${pkgs.zsh}/bin/zsh -i'
      '';
    in
    {
      services.udiskie = {
        enable = true;
        automount = true;
        notify = true;
        tray = "never";
        settings = {
          program_options = {
            file_manager = "${fileManager}";
          };
        };
      };
    };
}
