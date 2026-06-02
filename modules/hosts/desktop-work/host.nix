{ config, inputs, ... }:
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
    isLaptop = true;
    hasBluetooth = true;
    wireguardConfigName = "wireguard-laptop-asus";
    colorScheme = "catppuccin-mocha";

    enableRemoteSsh = false;
    enableRemoteDesktop = false;
    remoteSshAuthorizedKeys = [
      # Append SSH public keys here, e.g.:
      # "ssh-ed25519 AAAA... chek@laptop"
    ];

    # TODO: заменить заглушки на реальные данные с работы.
    # После замены — клонировать рабочие репо в ~/Work/ и
    # сгенерировать ключ: ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_work
    work = {
      name = "TODO-work-name";
      email = "TODO-work-email@example.com";
      # sshKeyPath = "/home/chek/.ssh/id_ed25519_work";
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
        inputs.nixos-hardware.nixosModules.asus-fa507nv
        ./_hardware-configuration.nix
      ];

      settings = sharedSettings;
    };
    modules.homeManager."hosts/${hostname}" = {
      imports = flakeConfig.flake.lib.loadHmModules modules;

      settings = sharedSettings;

      services.niri.blur.enable = false;

      services.niri.outputs.eDP-1 = {
        mode = "1920x1080@144.063";
        variableRefreshRate = "on-demand";
      };
      services.pttkey.bindings = {
        mouse = {
          keys = [ "BTN_EXTRA" ];
          devicePath = "/dev/input/event1";
        };
        kbd = {
          keys = [ "KEY_F13" ];
        };
      };
    };
  };
}
