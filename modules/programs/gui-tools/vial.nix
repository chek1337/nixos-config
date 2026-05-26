{
  flake.modules.nixos.vial =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.vial ];
      services.udev.packages = [ pkgs.vial ];
    };
}
