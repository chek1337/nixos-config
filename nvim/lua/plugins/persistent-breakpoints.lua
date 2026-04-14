return {
  "Weissle/persistent-breakpoints.nvim",
  event = "BufReadPost",
  config = function()
    require("persistent-breakpoints").setup({
      save_dir = vim.fn.stdpath("data") .. "/nvim_checkpoints",
      load_breakpoints_event = { "BufReadPost" },
      always_reload = true,
    })
    -- BufReadPost уже отработал к моменту ленивой загрузки плагина,
    -- поэтому вручную загружаем breakpoints для текущего буфера
    require("persistent-breakpoints.api").load_breakpoints()
  end,
}
