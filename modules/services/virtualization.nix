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

      programs.virt-manager.enable = true;

      users.users.${username}.extraGroups = [
        "libvirtd"
        "kvm"
      ];
    };

  flake.modules.homeManager.virtualization =
    { pkgs, ... }:
    {
      dconf.settings."org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
}
