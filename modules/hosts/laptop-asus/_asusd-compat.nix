# Workaround: nixos-hardware/asus/fa507nv sets services.asusd.enableUserService
# which nixpkgs removed via mkRemovedOptionModule.
# This module disables the stock asusd.nix and re-imports it without that assertion.
# TODO: Remove once nixos-hardware drops enableUserService.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.asusd;
  configType = lib.types.submodule (
    { ... }:
    {
      options = {
        text = lib.mkOption {
          default = null;
          type = lib.types.nullOr lib.types.lines;
          description = "Text of the file.";
        };
        source = lib.mkOption {
          default = null;
          type = lib.types.nullOr lib.types.path;
          description = "Path of the source file.";
        };
      };
    }
  );
  maybeConfig =
    name: cfg:
    lib.mkIf (cfg != null) (
      (if (cfg.source != null) then { source = cfg.source; } else { text = cfg.text; })
      // {
        mode = "0644";
      }
    );
in
{
  disabledModules = [ "services/hardware/asusd.nix" ];

  options.services.asusd = with lib.types; {
    enable = lib.mkEnableOption "the asusd service for ASUS ROG laptops";
    enableUserService = lib.mkOption {
      type = bool;
      default = false;
      description = "Deprecated no-op, kept for nixos-hardware compatibility.";
    };
    package = lib.mkPackageOption pkgs "asusctl" { };
    animeConfig = lib.mkOption {
      type = nullOr configType;
      default = null;
      description = "The content of /etc/asusd/anime.ron.";
    };
    asusdConfig = lib.mkOption {
      type = nullOr configType;
      default = null;
      description = "The content of /etc/asusd/asusd.ron.";
    };
    auraConfigs = lib.mkOption {
      type = attrsOf configType;
      default = { };
      description = "The content of /etc/asusd/aura_<name>.ron.";
    };
    profileConfig = lib.mkOption {
      type = nullOr configType;
      default = null;
      description = "The content of /etc/asusd/profile.ron.";
    };
    fanCurvesConfig = lib.mkOption {
      type = nullOr configType;
      default = null;
      description = "The content of /etc/asusd/fan_curves.ron.";
    };
    userLedModesConfig = lib.mkOption {
      type = nullOr configType;
      default = null;
      description = "The content of /etc/asusd/asusd-user-ledmodes.ron.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    environment.etc = {
      "asusd/anime.ron" = maybeConfig "anime.ron" cfg.animeConfig;
      "asusd/asusd.ron" = maybeConfig "asusd.ron" cfg.asusdConfig;
      "asusd/profile.ron" = maybeConfig "profile.ron" cfg.profileConfig;
      "asusd/fan_curves.ron" = maybeConfig "fan_curves.ron" cfg.fanCurvesConfig;
      "asusd/asusd_user_ledmodes.ron" = maybeConfig "asusd_user_ledmodes.ron" cfg.userLedModesConfig;
    }
    // lib.attrsets.concatMapAttrs (prod_id: value: {
      "asusd/aura_${prod_id}.ron" = maybeConfig "aura_${prod_id}.ron" value;
    }) cfg.auraConfigs;

    services.dbus.enable = true;
    systemd.packages = [ cfg.package ];
    services.dbus.packages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];
    services.supergfxd.enable = lib.mkDefault true;
  };
}
