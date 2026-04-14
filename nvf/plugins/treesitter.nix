{ pkgs, ... }:
{
  vim.treesitter.context.enable = false;

  vim.extraPlugins = with pkgs.vimPlugins; {
    nvim-treesitter-context = {
      package = nvim-treesitter-context;
      after = [ "nvim-treesitter" ];
      setup = ''
        require("treesitter-context").setup({
          enable = false,
          mode = "cursor",
        })

        vim.keymap.set("n", "gC", function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end, { silent = true, desc = "Jump to context" })

        vim.keymap.set("n", "<leader>uC", function()
          vim.cmd("silent TSContext toggle")
        end, { desc = "Toggle Treesitter Context" })
      '';
    };
  };
}
