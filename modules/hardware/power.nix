{
  flake.modules.nixos.power =
    { ... }:
    {
      services.upower = {
        enable = true;

        # Laptop setting
        # percentageLow = 20;
        # percentageCritical = 10;
        # percentageAction = 5;
        # criticalPowerAction = "HybridSleep";
      };

      # Laptop settings
      # services.power-profiles-daemon.enable = true;
      #
      # powerManagement = {
      #   enable = true;
      #   cpuFreqGovernor = "powersave";
      # };
    };
}
