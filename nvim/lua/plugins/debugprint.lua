return {
  "andrewferrier/debugprint.nvim",
  event = "VeryLazy",
  -- lazy = false, -- Required to make line highlighting work before debugprint is first used
  dependencies = {
    -- "nvim-mini/mini.hipatterns", -- Optional: Needed for line highlighting ('fine-grained' hipatterns plugin)
    "folke/snacks.nvim",
  },
  opts = {
    keymaps = {
      normal = {
        plain_below = "g?p",
        plain_above = "g?P",
        variable_below = "g?v",
        variable_above = "g?V",
        variable_below_alwaysprompt = "",
        variable_above_alwaysprompt = "",
        surround_plain = "g?sp",
        surround_variable = "g?sv",
        surround_variable_alwaysprompt = "",
        textobj_below = "g?o",
        textobj_above = "g?O",
        textobj_surround = "g?so",
        toggle_comment_debug_prints = "",
        delete_debug_prints = "",
      },
      visual = {
        variable_below = "g?v",
        variable_above = "g?V",
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "<leader>dpd", "<cmd>Debugprint delete<cr>",          mode = "n", desc = "Delete all debug prints" },
    { "<leader>dpc", "<cmd>Debugprint commenttoggle<cr>",   mode = "n", desc = "Toggle comment debug prints" },
    { "<leader>dpr", "<cmd>Debugprint resetcounter<cr>",    mode = "n", desc = "Reset counter" },
    { "<leader>dps", "<cmd>Debugprint search<cr>",          mode = "n", desc = "Search debug prints" },
    { "<leader>dpq", "<cmd>Debugprint qflist<cr>",          mode = "n", desc = "Debug prints → quickfix" },
  },
}
