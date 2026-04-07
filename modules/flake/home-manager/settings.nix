{ lib, ... }:
{
  flake.modules.homeManager.hmSettings =
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

        wireguardConfigName = lib.mkOption {
          type = lib.types.str;
          default = "wireguard-desktop-home";
          description = "Name of the sops-encrypted wireguard config file (without .conf)";
        };

        colorScheme = lib.mkOption {
          type = lib.types.str;
          default = "nord";
          description = "Base16 scheme name matching a file in pkgs.base16-schemes (e.g. nord, catppuccin-mocha)";
        };

        enableRice = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to spawn rice terminals on startup (nitch, lavat, nvim rice session)";
        };
      };
    };
}
