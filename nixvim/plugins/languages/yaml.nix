{ pkgs, config, ... }:
{
  plugins.lsp.servers.yamlls.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    yaml
  ];

  extraPackages = with pkgs; [
    yaml-language-server
  ];
}
