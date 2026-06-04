{ pkgs, config, ... }:
{
  plugins.lsp.servers.protols.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    proto
  ];

  plugins.conform-nvim.settings.formatters_by_ft.proto = [ "buf" ];

  extraPackages = with pkgs; [
    protols
    buf
  ];
}
