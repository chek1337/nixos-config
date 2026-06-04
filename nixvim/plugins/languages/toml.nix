{ pkgs, config, ... }:
{
  plugins.lsp.servers.taplo.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    toml
  ];

  extraPackages = with pkgs; [
    taplo
  ];
}
