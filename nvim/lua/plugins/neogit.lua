return {
  "NeogitOrg/neogit",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
    "esmuellert/codediff.nvim",
  },
  cmd = "Neogit",
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" },
  },
  opts = {
    graph_style = "kitty",
    integrations = {
      telescope = false,
      snacks = true,
      diffview = false,
      codediff = true,
    },
    diff_viewer = "codediff",
  },
}
