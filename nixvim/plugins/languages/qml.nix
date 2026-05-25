{ pkgs, config, ... }:
{
  plugins.lsp.servers.qmlls = {
    enable = true;
    package = pkgs.qt6.qtdeclarative;
    cmd = [ "${pkgs.qt6.qtdeclarative}/bin/qmlls" ];
  };

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    qmljs
  ];

  extraPackages = with pkgs; [
    qt6.qtdeclarative
  ];
}
