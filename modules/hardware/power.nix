{
  flake.modules.nixos.power =
    {
      config,
      lib,
      pkgs-stable,
      ...
    }:
    let
      isLaptop = config.settings.isLaptop;
      username = config.settings.username;
    in
    {
      services.upower = {
        enable = true;
      }
      // lib.optionalAttrs isLaptop {
        percentageLow = 20;
        percentageCritical = 10;
        percentageAction = 5;
        criticalPowerAction = "PowerOff";
      };

      powerManagement.enable = lib.mkIf isLaptop true;

      # Desktop: disable laptop-oriented services that may be pulled in
      services.power-profiles-daemon.enable = lib.mkIf (!isLaptop) (lib.mkForce false);

      # Laptop: idle management with swayidle
      environment.systemPackages = lib.mkIf isLaptop [ pkgs-stable.swayidle ];

      systemd.user.services.swayidle = lib.mkIf isLaptop {
        description = "Idle manager for Wayland";
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = lib.concatStringsSep " " [
            "${pkgs-stable.swayidle}/bin/swayidle -w"
            "timeout 300 'noctalia-shell ipc call lockScreen lock'"
            "timeout 600 'niri msg action power-off-monitors'"
            "resume 'niri msg action power-on-monitors'"
            "timeout 900 'systemctl suspend'"
          ];
          Restart = "on-failure";
        };
      };
    };
}
