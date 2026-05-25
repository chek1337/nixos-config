{ pkgs, config, ... }:
{
  plugins.lsp.servers.bashls.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    bash
  ];

  plugins.conform-nvim.settings.formatters_by_ft = {
    sh = [ "shfmt" ];
    bash = [ "shfmt" ];
    zsh = [ "shfmt" ];
  };

  plugins.lint.lintersByFt = {
    sh = [ "shellcheck" ];
    bash = [ "shellcheck" ];
  };

  extraPackages = with pkgs; [
    bash-language-server
    shfmt
    shellcheck
  ];
}
