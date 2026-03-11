return {
  "GCBallesteros/jupytext.nvim",
  event = "VeryLazy",
  config = function()
    require("jupytext").setup({
      style = "percent",
      output_extension = "py",
      force_ft = "python",
    })
  end,
}
