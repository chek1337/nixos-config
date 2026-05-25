{ pkgs, config, ... }:
{
  plugins.lsp.servers.html.enable = true;
  plugins.lsp.servers.cssls.enable = true;

  plugins.ts-autotag.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    html
    css
  ];

  plugins.conform-nvim.settings.formatters_by_ft = {
    html = [ "prettier" ];
    css = [ "prettier" ];
    scss = [ "prettier" ];
  };

  plugins.lint.lintersByFt.html = [ "htmlhint" ];

  extraPackages = with pkgs; [
    vscode-langservers-extracted
    htmlhint
  ];
}
