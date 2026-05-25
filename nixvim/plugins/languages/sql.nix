{ pkgs, config, ... }:
{
  plugins.lsp.servers.sqls.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    sql
  ];

  plugins.conform-nvim.settings.formatters_by_ft.sql = [ "sqlfluff" ];

  plugins.lint.lintersByFt.sql = [ "sqlfluff" ];

  extraPackages = with pkgs; [
    sqls
    sqlfluff
  ];
}
