{ pkgs, config, ... }:
{
  plugins.lsp.servers.texlab.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    latex
    bibtex
  ];

  plugins.conform-nvim.settings.formatters_by_ft.tex = [ "tex_fmt" ];

  extraPackages = with pkgs; [
    texlab
    tex-fmt
  ];
}
