{ pkgs, config, ... }:
{
  plugins.lsp.servers.ty.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    python
  ];

  plugins.conform-nvim.settings.formatters_by_ft.python = [
    "ruff_fix"
    "ruff_format"
  ];

  extraPackages = with pkgs; [
    ty
    ruff
  ];
}
