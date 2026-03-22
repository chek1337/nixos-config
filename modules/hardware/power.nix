{
  flake.modules.nixos.power =
    { config, lib, ... }:
    let
      isLaptop = config.settings.isLaptop;
    in
    {
      services.upower = {
        enable = true;
      } // lib.optionalAttrs isLaptop {
        percentageLow = 20;
        percentageCritical = 10;
        percentageAction = 5;
        criticalPowerAction = "PowerOff";
      };

      powerManagement.enable = lib.mkIf isLaptop true;

      # Desktop: disable laptop-oriented services that may be pulled in
      services.power-profiles-daemon.enable = lib.mkIf (!isLaptop) (lib.mkForce false);
    };
}
