return {
  "folke/snacks.nvim",
  priority = 10000,
  opts = {
    notifier = {
      timeout = 2000,
      style = "minimal",
    },
    dashboard = {
      enabled = true,
      preset = {
        -- https://github.com/MaximilianLloyd/ascii.nvim/blob/master/lua/ascii/text/neovim.lua
        header = [[

                                                                    
      ████ ██████           █████      ██                     
     ███████████             █████                             
     █████████ ███████████████████ ███   ███████████   
    █████████  ███    █████████████ █████ ██████████████   
   █████████ ██████████ █████████ █████ █████ ████ █████   
 ███████████ ███    ███ █████████ █████ █████ ████ █████  
██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      },
      sections = {
        { section = "header" },
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
    picker = {
      layout = "reverse_dropdown",
      layouts = {
        reverse_dropdown = {
          layout = {
            backdrop = false,
            row = 0,
            width = 0.95,
            min_width = 120,
            height = 0.99,
            border = "none",
            box = "vertical",
            {
              box = "vertical",
              border = true,
              title = "{title} {live} {flags}",
              title_pos = "center",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
            },
            { win = "preview", title = "{preview}", height = 0.7, border = true },
          },
        },
      },
    },
    indent = { enabled = true },
    scope = { enabled = true },
    quickfile = { enabled = true },
    scroll = {
      enabled = true,
      animate = {
        duration = { step = 10, total = 200 },
        -- https://github.com/kikito/tween.lua?tab=readme-ov-file#easing-functions
        easing = "outExpo", --  outExpo, outInExpo, outBack, outInExpo
      },
    },
    words = { enabled = true },
  },
  keys = {
    { "<leader>uC", false },
    { "<leader>dps", false },
  },
}

-- return { -- simple solution to change pickers
--   "folke/snacks.nvim",
--   opts = {
--     picker = {
--       layout = {
--         preset = "ivy_split", -- :help snacks-picker (9. Layouts)
--       },
--     },
--   },
-- }
