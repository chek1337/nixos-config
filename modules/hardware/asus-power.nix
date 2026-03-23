{
  flake.modules.nixos.asus-power =
    { config, lib, pkgs, ... }:
    let
      kbdColor = config.lib.stylix.colors.base00-hex;
      username = config.settings.username;

      modeForAc = "1920x1080@144.063";
      modeForBat = "1920x1080@60.061";

      # For udev (runs as root, needs to find user's niri socket)
      refreshRateUdev = pkgs.writeShellScript "refresh-rate-udev" ''
        ac_online=$(cat /sys/class/power_supply/ACAD/online 2>/dev/null || echo "0")
        if [ "$ac_online" = "1" ]; then
          mode="${modeForAc}"
        else
          mode="${modeForBat}"
        fi
        uid=$(${pkgs.coreutils}/bin/id -u ${username} 2>/dev/null || echo "")
        [ -z "$uid" ] && exit 0
        XDG_RUNTIME_DIR="/run/user/$uid" ${pkgs.niri}/bin/niri msg output eDP-2 mode "$mode" 2>/dev/null || true
      '';

      # For user service (already running as user)
      refreshRateUser = pkgs.writeShellScript "refresh-rate-user" ''
        ac_online=$(cat /sys/class/power_supply/ACAD/online 2>/dev/null || echo "0")
        if [ "$ac_online" = "1" ]; then
          mode="${modeForAc}"
        else
          mode="${modeForBat}"
        fi
        ${pkgs.niri}/bin/niri msg output eDP-2 mode "$mode" 2>/dev/null || true
      '';
    in
    {
      services.asusd.asusdConfig.text = ''
        (
            charge_control_end_threshold: 80,
            base_charge_control_end_threshold: 80,
            disable_nvidia_powerd_on_battery: true,
            ac_command: "",
            bat_command: "",
            platform_profile_linked_epp: true,
            platform_profile_on_battery: Quiet,
            change_platform_profile_on_battery: true,
            platform_profile_on_ac: Performance,
            change_platform_profile_on_ac: true,
            profile_quiet_epp: Power,
            profile_balanced_epp: BalancePower,
            profile_custom_epp: Performance,
            profile_performance_epp: Performance,
            ac_profile_tunings: {},
            dc_profile_tunings: {},
            armoury_settings: {},
        )
      '';

      # Keep sysfs service in sync with asusd config
      hardware.asus.battery.chargeUpto = 80;

      # Keyboard backlight color from stylix palette
      systemd.services.asusctl-aura = {
        description = "Set ASUS keyboard backlight color";
        after = [ "asusd.service" ];
        wants = [ "asusd.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.asusctl}/bin/asusctl aura effect static -c ${kbdColor}";
          RemainAfterExit = true;
        };
      };

      # Switch display refresh rate based on AC/battery
      services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="${refreshRateUdev}"
      '';

      # Set initial refresh rate on login
      systemd.user.services.refresh-rate-init = {
        description = "Set display refresh rate based on power source";
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = refreshRateUser;
          RemainAfterExit = true;
        };
      };

      environment.systemPackages = [
        pkgs.asusctl
        pkgs.supergfxctl
      ];
    };
}
