{ inputs, ... }:
{
  flake.modules.nixos.nixos =
    { pkgs, ... }:
    {
      imports = [ inputs.elegant-grub2-themes.nixosModules.default ];

      stylix.targets.grub.enable = false;
      boot = {
        kernelPackages = pkgs.linuxPackages_latest;

        # Тихая загрузка: глушим консольный лог ядра/initrd/udev, чтобы поздние
        # сообщения не сыпались на VT поверх tuigreet и не ломали его вывод.
        consoleLogLevel = 0;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "udev.log_level=3"
          "rd.udev.log_level=3"
          "vt.global_cursor_default=0"
        ];

        loader = {
          grub = {
            enable = true;
            devices = [ "nodev" ];
            efiSupport = true;
            useOSProber = true;
            # configurationLimit = 20;
          };
          efi.canTouchEfiVariables = true;
          elegant-grub2-theme = {
            enable = true;
            theme = "forest";
            type = "sharp";
            side = "right";
            color = "dark";
            screen = "1080p";
            logo = "system";
          };
        };
      };
    };
}
