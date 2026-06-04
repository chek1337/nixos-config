{ pkgs, config, ... }:
{
  # LSP: protols (Rust, standalone). Форматирование делает сам через
  # clang-format (берётся из clang-tools, уже подтянут в clang.nix),
  # поэтому отдельный formatter в conform не нужен.
  plugins.lsp.servers.protols.enable = true;

  # buf_ls — включать только в проектах с buf.yaml/buf.work.yaml
  # plugins.lsp.servers.buf_ls.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    proto
  ];

  # Форматирование идёт через LSP (protols -> clang-format).
  # plugins.conform-nvim.settings.formatters_by_ft.proto = [ "buf" ];

  extraPackages = with pkgs; [
    protols
    # buf  # нужен только при использовании buf_ls / buf format
  ];
}
