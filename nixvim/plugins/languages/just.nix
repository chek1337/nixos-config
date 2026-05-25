{ pkgs, config, ... }:
{
  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    just
  ];

  extraPackages = with pkgs; [
    just-lsp
  ];

  extraConfigLua = ''
    vim.lsp.config("just_lsp", {
      cmd = { "just-lsp" },
      filetypes = { "just" },
      root_markers = { "justfile", ".justfile", ".git" },
    })
    vim.lsp.enable("just_lsp")
  '';
}
