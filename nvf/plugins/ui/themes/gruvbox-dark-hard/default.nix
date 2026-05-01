{ pkgs }:
{
  package = pkgs.vimPlugins.gruvbox-nvim;

  setup = # lua
    ''
      require("gruvbox").setup({ contrast = "hard" })
      vim.cmd.colorscheme("gruvbox")
    '';
}
