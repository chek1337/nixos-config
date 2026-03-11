return {
  "MagicDuck/grug-far.nvim",

  cmd = { "GrugFar", "GrugFarWithin" },
  opts = {
    headerMaxWidth = 80,
    enabledEngines = { "ripgrep", "astgrep" },
    extraRgArgs = "",
    startInInsertMode = false,
  },

  keys = {
    -- still have "<leader>sr" fallback
    {
      "<leader>srr",
      function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
      end,
      mode = { "n", "x" },
      desc = "Search and Replace in Project",
    },
    {
      "<leader>srf",
      function()
        require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
      end,
      mode = { "n", "x" },
      desc = "Search and Replace in File",
    },
    {
      "<leader>srv",
      function()
        require("grug-far").open({ visualSelectionUsage = "operate-within-range" })
      end,
      mode = { "n", "x" },
      desc = "Search and Replace for Current Visual Selection",
    },
    -- {
    --   "<leader>srw", just use visual selection and press "<leader>sr(r/f)"....
    --   function()
    --     require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
    --   end,
    --   mode = { "n", "x" },
    --   desc = "Search and Replace for Current Word",
    -- },
    -- { -- Difference between .open()?
    --   "<leader>srv",
    --   function()
    --     require("grug-far").with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
    --   end,
    --   mode = { "v" },
    --   desc = "Search and Replace for Current Word",
    -- },
  },
}

-- return {
--   "MagicDuck/grug-far.nvim",
--   opts = {
--     enabledEngines = { "ripgrep", "astgrep" },
--     extraRgArgs = "",
--     startInInsertMode = true,
--   },
-- }
