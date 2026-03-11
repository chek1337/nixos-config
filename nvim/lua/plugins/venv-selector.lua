return {
  "linux-cultist/venv-selector.nvim",
  event = "VeryLazy",
  dependencies = {
    "neovim/nvim-lspconfig",
    "folke/snacks.nvim",
  },
  ft = "python",
  keys = {
    { "<localleader>v", "<cmd>VenvSelect<cr>" },
  },
  opts = {
    search = {},
    options = {
      picker = "snacks",
      picker_options = {
        snacks = {
          layout = {
            preset = "select",
          },
        },
      },
    },
  },
}