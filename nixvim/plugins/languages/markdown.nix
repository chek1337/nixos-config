{ pkgs, config, ... }:
{
  plugins.lsp.servers.marksman.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    markdown
    markdown_inline
  ];

  plugins.conform-nvim.settings.formatters_by_ft.markdown = [ "deno_fmt" ];

  plugins.lint.lintersByFt.markdown = [ "markdownlint-cli2" ];

  extraPackages = with pkgs; [
    marksman
    deno
    markdownlint-cli2
  ];
}
