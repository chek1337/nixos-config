{ pkgs, config, ... }:
{
  plugins.lsp.servers.csharp_ls.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    c_sharp
  ];

  extraPackages = with pkgs; [
    csharp-ls
  ];
}
