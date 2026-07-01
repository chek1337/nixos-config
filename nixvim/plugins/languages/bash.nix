{ pkgs, config, ... }:
{
  plugins.lsp.servers.bashls = {
    enable = true;
    # Нет отдельного zsh-LSP — вешаем bashls и на zsh-файлы.
    filetypes = [
      "sh"
      "bash"
      "zsh"
    ];
  };

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    bash
  ];

  plugins.conform-nvim.settings.formatters_by_ft = {
    sh = [ "shfmt" ];
    bash = [ "shfmt" ];
    # shfmt не умеет zsh-диалект (только bash/posix/mksh/bats) — тут beautysh.
    zsh = [ "beautysh" ];
  };

  plugins.lint.lintersByFt = {
    sh = [ "shellcheck" ];
    bash = [ "shellcheck" ];
  };

  extraPackages = with pkgs; [
    bash-language-server
    shfmt
    beautysh
    shellcheck
  ];
}
