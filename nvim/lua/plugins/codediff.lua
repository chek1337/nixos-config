return {
  "esmuellert/codediff.nvim",
  dependencies = { "MunifTanjim/nui.nvim", event = "VeryLazy" },
  event = "VeryLazy",
  cmd = "CodeDiff",
  keys = {
    -- "<leader>gd" opening default git diff from Snacks.nvim (fallback)
    { "<leader>gdd", ":CodeDiff<CR>", silent = true, desc = "Open Codediff" },
    {
      "<leader>gdD",
      function()
        vim.fn.feedkeys(":CodeDiff ", "n")
      end,
      silent = true,
      desc = "Open Codediff to Enter Prompt",
    },
    {
      "<leader>gdf",
      ":CodeDiff file HEAD<CR>",
      silent = true,
      desc = "Open Codediff for Current File and Last Commit",
    },
    {
      "<leader>gdF",
      function()
        vim.fn.feedkeys(":CodeDiff file ", "n")
      end,
      silent = true,
      desc = "Open Codediff for File to Enter Prompt",
    },
    { "<leader>gdhh", ":CodeDiff history<CR>", silent = true, desc = "Open Codediff History" },
    {
      "<leader>gdhH",
      function()
        vim.fn.feedkeys(":CodeDiff history ", "n")
      end,
      silent = true,
      desc = "Open Codediff History to Enter Prompt",
    },
    { "<leader>gdhf", ":CodeDiff history %<CR>", silent = true, desc = "Open Codediff History for Current File" },
  },

  opts = {
    explorer = {
      position = "bottom",
      height = 10,
      file_filter = {
        ignore = {},
      },
    },
    history = {
      position = "bottom",
      height = 10,
      file_filter = {
        ignore = {},
      },
    },
  },
}
