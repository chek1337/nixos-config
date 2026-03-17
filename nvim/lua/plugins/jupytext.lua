return {
  "GCBallesteros/jupytext.nvim",
  event = "BufReadPre *.ipynb",
  config = function()
    require("jupytext").setup({
      style = "percent",
      output_extension = "py",
      force_ft = "python",
    })
  end,
}
