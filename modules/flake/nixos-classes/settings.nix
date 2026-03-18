{ lib, ... }:
{
  flake.modules.nixos.settings =
    { lib, ... }:
    {
      options.settings.username = lib.mkOption {
        type = lib.types.str;
        description = "Primary user's username";
      };
    };
}
