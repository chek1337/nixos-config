{ inputs, ... }:
{
  perSystem =
    { config, system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      nixvimPkg = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        # Прокидываем обёрнутый standalone-yazi (packages/yazi.nix), чтобы
        # плагин qol/yazi брал именно его — с конфигом и рантайм-деками, а не
        # голый pkgs.yazi.
        extraSpecialArgs = {
          yaziPkg = config.packages.yazi;
        };
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
