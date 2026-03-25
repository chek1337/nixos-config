{ config, ... }:
{
  flake.modules.nixos.mail = {
    imports = with config.flake.modules.nixos; [
      email-accounts
    ];
  };

  flake.modules.homeManager.mail = {
    imports = with config.flake.modules.homeManager; [
      email-accounts
      aerc
      thunderbird
    ];
  };
}
