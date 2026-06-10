{ pkgs, config, ... }:
{
  # plugins.lsp.servers.gopls.enable = true;
  #
  # plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
  #   go
  #   gomod
  #   gosum
  #   gowork
  # ];
  #
  # plugins.conform-nvim.settings.formatters_by_ft.go = [ "gofmt" ];
  #
  # plugins.lint.lintersByFt.go = [ "golangcilint" ];
  #
  # extraPackages = with pkgs; [
  #   gopls
  #   go
  #   golangci-lint
  # ];
}
