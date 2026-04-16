{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    scope-nvim = {
      package = scope-nvim;
      setup = ''require("scope").setup({})'';
    };
  };
}
