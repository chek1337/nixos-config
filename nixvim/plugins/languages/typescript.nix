{ pkgs, config, ... }:
{
  plugins.lsp.servers.ts_ls.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    typescript
    tsx
    javascript
  ];

  plugins.conform-nvim.settings.formatters_by_ft = {
    javascript = [ "prettier" ];
    javascriptreact = [ "prettier" ];
    typescript = [ "prettier" ];
    typescriptreact = [ "prettier" ];
  };

  plugins.lint.lintersByFt = {
    javascript = [ "eslint_d" ];
    javascriptreact = [ "eslint_d" ];
    typescript = [ "eslint_d" ];
    typescriptreact = [ "eslint_d" ];
  };

  extraPackages = with pkgs; [
    typescript-language-server
    prettier
    eslint_d
  ];
}
