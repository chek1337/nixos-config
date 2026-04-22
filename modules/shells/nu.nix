# Shell option: nu
# Select in hosts/*/host.nix via: shell = "nu"
{
  flake.modules.nixos.nu =
    { pkgs, config, ... }:
    let
      username = config.settings.username;
    in
    {
      users.users.${username}.shell = pkgs.nushell;
    };

  flake.modules.homeManager.nu =
    { ... }:
    {
      programs.nushell = {
        enable = true;
      };

      programs.starship = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
}
