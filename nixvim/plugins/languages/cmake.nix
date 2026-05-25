{ pkgs, config, ... }:
{
  plugins.lsp.servers.cmake.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    cmake
  ];

  plugins.conform-nvim.settings.formatters_by_ft.cmake = [ "gersemi" ];

  extraPackages = with pkgs; [
    cmake-language-server
    gersemi
  ];
}
