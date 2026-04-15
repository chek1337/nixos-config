{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    nvim-dap-python = {
      package = nvim-dap-python;
      setup = ''require("dap-python").setup("debugpy-adapter")'';
      after = [ "nvim-dap" ];
    };
  };
}
