{ inputs, ... }:
{
  flake.modules.homeManager.nvf =
    { ... }:
    {
      stylix.targets.neovim.enable = false;
      stylix.targets.nvf.enable = false;

      imports = [ inputs.nvf.homeManagerModules.default ];

      programs.nvf = {
        enable = true;
        settings.imports = [
          ./options.nix
          ./keymaps.nix
          ./lsp.nix
          ./plugins
        ];
      };

      programs.zsh.shellAliases.v = "nvim";
    };
}
