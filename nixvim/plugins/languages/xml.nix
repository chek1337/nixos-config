{ config, ... }:
{
  plugins.lsp.servers.lemminx.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    xml
  ];
}
