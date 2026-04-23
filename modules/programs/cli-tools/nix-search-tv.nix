{
  flake.modules.homeManager.nix-search-tv = {
    programs.nix-search-tv = {
      enable = true;
      settings = {
        indexes = [
          "nixpkgs"
          "nixos"
          "home-manager"
          "nur"
          "noogle"
        ];
      };
    };
  };
}
