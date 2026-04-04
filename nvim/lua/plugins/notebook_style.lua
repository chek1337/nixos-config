return {
  "stellarjmr/notebook_style.nvim",
  ft = "python",
  config = function(_, opts)
    local scheme = vim.g.colors_name or ""
    opts.colors = scheme:find("catppuccin") and { border = "#585b70", delimiter = "#414162" }
               or scheme == "gruvbox" and { border = "#504945", delimiter = "#3c3836" }
               or { border = "#3b4252", delimiter = "#2e3440" } -- nord + fallback
    require("notebook_style").setup(opts)
  end,
  opts = {
    border_style = "my_style",
    cell_width_percentage = 100, -- Cell width as % of window width (1-100)
    min_cell_width = 200, -- Minimum cell width in characters
    max_cell_width = 200, -- Maximum cell width in characters
    hide_border_in_insert = false,
    manual_render = false,
    border_chars = {
      my_style = {
        top_left = "",
        top_right = "",
        bottom_left = "",
        bottom_right = "",
        horizontal = "━",
        vertical = "",
      },
    },
  },
}
