{ lib, ... }:
{
  flake.modules.nixos.settings =
    { lib, config, ... }:
    {
      options.settings = {
        username = lib.mkOption {
          type = lib.types.str;
          description = "Primary user's username";
        };

        hostType = lib.mkOption {
          type = lib.types.enum [
            "desktop"
            "wsl"
            "server"
          ];
          description = "Type of this host";
        };

        isDesktop = lib.mkOption {
          type = lib.types.bool;
          default = config.settings.hostType == "desktop";
          readOnly = true;
          description = "Whether this is a desktop host";
        };

        isWSL = lib.mkOption {
          type = lib.types.bool;
          default = config.settings.hostType == "wsl";
          readOnly = true;
          description = "Whether this is a WSL host";
        };

        isServer = lib.mkOption {
          type = lib.types.bool;
          default = config.settings.hostType == "server";
          readOnly = true;
          description = "Whether this is a server host";
        };

        wireguardConfigName = lib.mkOption {
          type = lib.types.str;
          default = "wireguard-desktop-home";
          description = "Name of the sops-encrypted wireguard config file (without .conf)";
        };

        isLaptop = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether this is a laptop (portable) host";
        };

        hasBluetooth = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether this host has bluetooth";
        };

        timeZone = lib.mkOption {
          type = lib.types.str;
          default = "Asia/Novosibirsk";
          description = "System timezone";
        };

        stateVersion = lib.mkOption {
          type = lib.types.str;
          default = "25.11";
          description = "NixOS and home-manager state version";
        };

        colorScheme = lib.mkOption {
          type = lib.types.str;
          default = "nord";
          description = "Base16 scheme name matching a file in pkgs.base16-schemes (e.g. nord, catppuccin-mocha)";
        };
      };
    };
}
