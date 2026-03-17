return {
  "nvim-treesitter/nvim-treesitter-context",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    {
      "gC",
      function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end,
      mode = "n",
      silent = true,
      desc = "Jump to context",
    },
    {
      "<leader>uC",
      function()
        vim.cmd("silent TSContext toggle")
      end,
      mode = "n",
      desc = "Toggle Treesitter Context",
    },
  },
  opts = {
    enable = false,
    mode = "cursor", -- 'cursor'/'topline'
  },
  config = function(_, opts)
    require("treesitter-context").setup(opts)
    -- vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#181825" })
    -- vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { fg = "#45475a" })
    --
    -- vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "Grey" })
    -- vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = true, sp = "Grey" })
  end,
}
