{ pkgs, config, ... }:
{
  plugins.lsp.servers.dockerls.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    dockerfile
  ];

  extraPackages = with pkgs; [
    dockerfile-language-server
  ];
}
