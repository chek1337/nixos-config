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
      ];
      nix.settings = {
        max-jobs = "auto";
        cores = 0;
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          # "https://zen-browser.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          # "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
        ];
        keep-outputs = true;
        keep-derivations = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.permittedInsecurePackages = [
        # "openssl-1.1.1w"
      ];
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
