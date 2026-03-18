{ inputs, ... }:
{
  flake.modules.nixos.nixos =
    { config, ... }:
    let
      username = config.settings.username;
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.hyprland.nixosModules.default
      ];
      nix.settings = {
        substituters = [
          "https://cache.nixos.org"
          "https://hyprland.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
      home-manager.backupFileExtension = "backup";
      users.users.${username} = {
        isNormalUser = true;
        home = "/home/${username}";
        extraGroups = [ "wheel" ];
      };
      time.timeZone = config.settings.timeZone;
      programs.nix-ld.enable = true;
    };
}
