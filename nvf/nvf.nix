{ inputs, ... }:
{
  flake.modules.homeManager.nvf =
    { config, lib, ... }:
    {
      stylix.targets.neovim.enable = false;
      stylix.targets.nvf.enable = false;

      imports = [ inputs.nvf.homeManagerModules.default ];

      programs.nvf = {
        enable = true;
        settings = {
          imports = [
            ./options.nix
            ./keymaps.nix
            ./lsp.nix
            ./plugins
          ];
          _module.args.stylixColors = config.lib.stylix.colors;
        };
      };

      # Победить в коллизии с lazyvim-nix (приоритет 5 по умолчанию)
      home.packages = [ (lib.hiPrio config.programs.nvf.finalPackage) ];

      programs.zsh.shellAliases.v = "nvim";
    };
}
