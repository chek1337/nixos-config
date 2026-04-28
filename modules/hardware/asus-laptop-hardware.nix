{
  flake.modules.nixos.asus-laptop-hardware =
    {
      config,
      lib,
      pkgs-stable,
      ...
    }:
    let
      kbdColor = config.lib.stylix.colors.base00-hex;
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
          ExecStart = "${pkgs-stable.asusctl}/bin/asusctl aura effect static -c ${kbdColor}";
          RemainAfterExit = true;
        };
      };

      services.supergfxd.enable = true;

      environment.systemPackages = [
        pkgs-stable.asusctl
        pkgs-stable.supergfxctl
      ];
    };
}
