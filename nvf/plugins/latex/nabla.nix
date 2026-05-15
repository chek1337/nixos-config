{ pkgs, ... }:
{
  vim.treesitter.grammars = [ pkgs.vimPlugins.nvim-treesitter.builtGrammars.latex ];

  vim.extraPlugins = with pkgs.vimPlugins; {
    nabla-nvim = {
      package = nabla-nvim;
      setup = # lua
        ''
          vim.api.nvim_create_autocmd("FileType", {
            pattern = { "tex", "plaintex", "context" },
            callback = function(args)
              local o = { buffer = args.buf }
              vim.keymap.set("n", "<leader>lp", function()
                require("nabla").popup({ border = "rounded" })
              end, vim.tbl_extend("force", o, { desc = "Popup preview" }))
              vim.keymap.set("n", "<leader>lP", function()
                require("nabla").toggle_virt()
              end, vim.tbl_extend("force", o, { desc = "Toggle inline preview" }))
            end,
          })
        '';
    };
  };
}
