{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    render-markdown-nvim = {
      package = render-markdown-nvim;
      setup = ''require("render-markdown").setup({})'';
    };
  };
}
