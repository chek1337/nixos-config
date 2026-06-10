{ pkgs, config, ... }:
{
  # plugins.lsp.servers.phpactor.enable = true;
  #
  # plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
  #   php
  # ];
  #
  # plugins.conform-nvim.settings.formatters_by_ft.php = [ "php_cs_fixer" ];
  #
  # extraPackages = with pkgs; [
  #   phpactor
  #   phpPackages.php-cs-fixer
  # ];
}
