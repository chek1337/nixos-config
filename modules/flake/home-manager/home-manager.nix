{
  flake.modules.homeManager.homeManager =
    { ... }:
    {
      programs.home-manager.enable = true;
      home.stateVersion = "25.05";
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };
}
