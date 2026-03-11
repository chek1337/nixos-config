return {
  "igorlfs/nvim-dap-view",
  event = "VeryLazy",
  keys = {
    {
      "<leader>dd",
      function()
        vim.cmd("DapViewToggle!")
      end,
      desc = "Debug: Toggle dap-view (open / close + term)",
    },
    {
      "<leader>dx",
      function()
        vim.cmd("DapViewClose!")
      end,
      desc = "Debug: Close dap-view force",
    },
    { "<leader>dw", "<Cmd>DapViewWatch<CR>", desc = "Debug: Add Variable to Scope" },
  },
  opts = {
    winbar = {
      sections = { "watches", "scopes", "breakpoints", "repl", "exceptions", "threads", "sessions" },
      controls = {
        enabled = true,
        position = "right",
      },
    },
    windows = {
      size = 0.35,
      position = "below",
      terminal = {
        size = 0.45,
        position = "right",
      },
    },
    auto_toggle = true,
  },
}
