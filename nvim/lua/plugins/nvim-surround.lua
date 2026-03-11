return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  enabled = false, -- now using mini.surround
  opts = {
    keymaps = {
      -- Capital S and C - is block additon
      insert = "<M-g>s", -- woring like autopairs but why i should it use?
      insert_line = "<M-g>S", -- same
      normal = "gs",
      normal_cur = "gss",
      normal_line = "gsS",
      normal_cur_line = "gSS",
      visual = "gs",
      visual_line = "gS",
      delete = "gsd",
      change = "gsc",
      change_line = "gsC",
    },
    surrounds = {
      ["c"] = {
        add = function()
          return {
            { "/* " },
            { " */" },
          }
        end,
        find = function()
          local config = require("nvim-surround.config")
          return config.get_selection({
            pattern = "/%*.-%*/",
          })
        end,
        delete = function()
          local config = require("nvim-surround.config")
          return config.get_selections({
            char = "c",
            pattern = "^(%/%*%s*)().-(%s*%*%/)()$",
          })
        end,
      },
    },
  },
}
