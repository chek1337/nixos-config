{ pkgs, ... }:
{
  vim.treesitter.grammars = [ pkgs.vimPlugins.nvim-treesitter.builtGrammars.latex ];

  vim.extraPlugins = with pkgs.vimPlugins; {
    nabla-nvim = {
      package = nabla-nvim;
      setup = # lua
        ''
          vim.keymap.set("n", "<leader>lp", function()
            require("nabla").popup({ border = "rounded" })
          end, { desc = "LaTeX popup preview" })

          vim.keymap.set("n", "<leader>lP", function()
            require("nabla").toggle_virt()
          end, { desc = "LaTeX toggle inline preview" })
        '';
    };
  };
}
