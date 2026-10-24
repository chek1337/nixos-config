{ inputs, config, ... }:
let
  flakeConfig = config;
in
{
  perSystem =
    { config, system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        # nvim-dap / nvim-lint качаются с недоступного Codeberg — см.
        # modules/nixos-params/vim-plugins-github-mirror.nix
        overlays = [ flakeConfig.flake.overlays.vimPluginsGithubMirror ];
      };
      nixvimPkg = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        # Прокидываем обёрнутый standalone-yazi (packages/yazi.nix), чтобы
        # плагин qol/yazi брал именно его — с конфигом и рантайм-деками, а не
        # голый pkgs.yazi.
        extraSpecialArgs = {
          yaziPkg = config.packages.yazi;
          # Зеркалит _module.args.pkgs-stable из nixvim/nixvim.nix: ./plugins
          # общие для HM- и standalone-сборки, так что arg нужен в обоих местах.
          pkgs-stable = import inputs.nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        module = {
          imports = [
            ../nixvim/options.nix
            ../nixvim/keymaps.nix
            ../nixvim/keymaps-ru.nix
            ../nixvim/spellfiles.nix
            ../nixvim/plugins
          ];
          colorScheme = "dynamic";
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
