{ inputs, ... }:
{
  flake.modules.homeManager.nvim =
    { pkgs, ... }:
    {
      imports = [ inputs.lazyvim-nix.homeManagerModules.default ];

      programs.lazyvim = {
        enable = true;
        configFiles = ./nvim;
        extraPackages = with pkgs; [
          ty
          ruff
          nixd
          nixfmt
          lua-language-server
          stylua
        ];
        treesitterParsers = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
          nix
        ];
      };

      programs.zsh.shellAliases = {
        v = "nvim";
      };
    };
}
