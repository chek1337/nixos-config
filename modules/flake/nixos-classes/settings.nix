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

        timeZone = lib.mkOption {
          type = lib.types.str;
          default = "Asia/Novosibirsk";
          description = "System timezone";
        };

        stateVersion = lib.mkOption {
          type = lib.types.str;
          default = "25.05";
          description = "NixOS and home-manager state version";
        };
      };
    };
}
