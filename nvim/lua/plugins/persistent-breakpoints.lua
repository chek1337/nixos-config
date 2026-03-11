return {
  "Weissle/persistent-breakpoints.nvim",
  event = "VeryLazy",
  config = function()
    require("persistent-breakpoints").setup({
      save_dir = vim.fn.stdpath("data") .. "/nvim_checkpoints",
      load_breakpoints_event = { "BufReadPost" },
      always_reload = true,
    })
  end,
}
