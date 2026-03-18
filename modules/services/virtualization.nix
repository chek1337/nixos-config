{ ... }:
{
  flake.modules.nixos.virtualization =
    { pkgs, username, ... }:
    {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true;
        };
      };

      i18n.extraLocales = [ "ru_RU.UTF-8/UTF-8" ];

      programs.virt-manager.enable = true;

      users.users.${username}.extraGroups = [
        "libvirtd"
        "kvm"
      ];

      systemd.services.libvirtd-default-network = {
        description = "Autostart libvirt default NAT network";
        after = [ "libvirtd.service" ];
        requires = [ "libvirtd.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        path = [ pkgs.libvirt ];
        script = ''
          virsh net-autostart default
          virsh net-start default || true
        '';
      };
    };

  flake.modules.homeManager.virtualization =
    { pkgs, ... }:
    {
      dconf.settings."org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };

      xdg.desktopEntries.virt-manager = {
        name = "Virtual Machine Manager";
        exec = "env LANG=ru_RU.UTF-8 LANGUAGE=ru_RU:ru virt-manager";
        icon = "virt-manager";
        categories = [ "System" ];
        comment = "Manage virtual machines";
      };
    };
}
