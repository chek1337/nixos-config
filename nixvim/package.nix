{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      nixvimPkg = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = {
          imports = [
            ./options.nix
            ./plugins
          ];
        };
      };
    in
    {
      packages.nixvim = nixvimPkg;
      apps.nixvim = {
        type = "app";
        program = "${nixvimPkg}/bin/nvim";
      };
    };
}
