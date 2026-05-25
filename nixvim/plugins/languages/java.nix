{ pkgs, config, ... }:
{
  plugins.lsp.servers.jdtls.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    java
  ];

  extraPackages = with pkgs; [
    jdt-language-server
  ];
}
