# Shell option: nu
# Select in hosts/*/default.nix via: shell = "nu"
{
  flake.modules.nixos.nu =
    { pkgs, username, ... }:
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
