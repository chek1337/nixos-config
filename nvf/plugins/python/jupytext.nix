{ pkgs, ... }:
{
  vim.extraPackages = [ pkgs.python3Packages.jupytext ];

  vim.extraPlugins = with pkgs.vimPlugins; {
    jupytext-nvim = {
      package = jupytext-nvim;
      setup = # lua
        ''
          require("jupytext").setup({
            style = "percent",
            output_extension = "py",
            force_ft = "python",
          })
        '';
    };
  };
}
