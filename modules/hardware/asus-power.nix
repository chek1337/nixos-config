{
  flake.modules.nixos.asus-power =
    { lib, pkgs, ... }:
    {
      hardware.asus.battery = {
        chargeUpto = lib.mkForce 80;
        enableChargeUptoScript = true;
      };

      environment.systemPackages = [
        pkgs.asusctl
        pkgs.supergfxctl
      ];
    };
}
