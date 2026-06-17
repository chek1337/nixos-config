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
            ./keymaps.nix
            ./keymaps-ru.nix
            ./spellfiles.nix
            ./plugins
          ];
          colorScheme = "nord";
        };
      };
    in
    {
      packages.nvim = nixvimPkg;
      apps.nvim = {
        type = "app";
        program = "${nixvimPkg}/bin/nvim";
      };
    };
}
