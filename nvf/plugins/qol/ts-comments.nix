{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    ts-comments-nvim = {
      package = ts-comments-nvim;
      setup = ''require("ts-comments").setup({})'';
    };
  };
}
