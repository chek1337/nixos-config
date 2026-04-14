return {
  "uga-rosa/ccc.nvim",
  lazy = true,
  cmd = { "CccPick", "CccHighlighterToggle", "CccConvert" },
  keys = {
    { "<leader>Cp", "<cmd>CccPick<CR>", mode = { "n", "x" }, desc = "Color Picker" },
    { "<leader>Ct", "<cmd>CccHighlighterToggle<CR>", mode = { "n", "x" }, desc = "Color Highlighter Toggle" },
    { "<leader>Cc", "<cmd>CccConvert<CR>", mode = { "n", "x" }, desc = "Color Convert" },
  },
  config = function()
    local ccc = require("ccc")

    ccc.setup({
      highlighter = {
        auto_enable = true,
        lsp = true,
      },
    })

  end,
}
