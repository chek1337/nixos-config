{ config, ... }:
let
  flakeConfig = config;
  hostname = "desktop-work";
  username = "chek";
  modules = [
    "desktop"
    "workstation"
    "networking"
    "remote-access"
  ];
  sharedSettings = {
    hasBluetooth = true;
    wireguardConfigName = "wireguard-desktop-work";
    wireguardExtraConfigs = [ "wireguard-isakin" ];
    amneziaWgExtraConfigs = [
      "amnezia-chumakov"
      "amnezia-chumakov-2"
    ];
    colorScheme = "nord";

    enableRemoteSsh = true;
    enableRemoteDesktop = true;
    enableMoonlightClient = true;
    remoteSshAuthorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA213f/P1prxD2ImqqW6goD6iBsHH8E5HvEOf+R/dkk8 chek@wsl-asuslaptop"
    ];

    work = {
      name = "Лойченко Данила";
      email = "danila.loichenko@eltex.loc";
      sshKeyPath = "/home/chek/.ssh/09_06_26_work";
    };
  };
in
{
  flake = {
    nixosConfigurations.${hostname} = flakeConfig.flake.lib.mkSystems.linux username hostname;
    nixosConfigurations."iso-${hostname}" = flakeConfig.flake.lib.mkSystems.iso username hostname;
    homeConfigurations."${username}@${hostname}" =
      flakeConfig.flake.lib.mkHomes.home-linux username hostname;

    modules.nixos."hosts/${hostname}" = {
      imports = (flakeConfig.flake.lib.loadNixosModules modules) ++ [
        ./_hardware-configuration.nix
      ];

      settings = sharedSettings;
    };
    modules.homeManager."hosts/${hostname}" = {
      imports = flakeConfig.flake.lib.loadHmModules modules;

      settings = sharedSettings;

      services.niri.blur.enable = false;

      # TODO: имена выходов и mode подобрать под реальные мониторы после
      # первой загрузки (`niri msg outputs`). Скопировано из desktop-home как
      # отправная точка для двухмониторной раскладки.
      services.niri.outputs.DP-1 = {
        position = {
          x = 0;
          y = 180;
        };
      };
      services.niri.outputs.HDMI-A-1 = {
        mode = "1920x1080@60.000";
        position = {
          x = 1600;
          y = 0;
        };
      };
      services.pttkey.bindings = {
        mouse = {
          keys = [ "BTN_EXTRA" ];
          # TODO: подставить путь USB-мыши с реальной машины (ls /dev/input/by-id/).
          devicePath = "/dev/input/by-id/usb-E-Signal_USB_Gaming_Mouse-event-mouse";
        };
        kbd = {
          keys = [ "KEY_F13" ];
        };
      };
    };
  };
}
