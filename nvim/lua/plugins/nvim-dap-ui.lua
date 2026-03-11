local float_params = {
  width = 100,
  height = 100,
  enter = true,
  position = "center",
}

return {
  -- "rcarriga/nvim-dap-ui",
  -- dependencies = { "nvim-neotest/nvim-nio" },
  --   -- stylua: ignore
  --   keys = {
  --     { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
  --     { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "x"} },
  --     { "<leader>dfs",
  --       function()
  --         require("dapui").float_element("scopes", float_params)
  --       end,
  --       desc = "Open Floating Scopes", mode = {"n", "x"} },
  --     { "<leader>dfS",
  --       function()
  --         require("dapui").float_element("stacks", float_params)
  --       end,
  --       desc = "Open Floating Stacks", mode = {"n", "x"} },
  --     { "<leader>dfw",
  --       function()
  --         require("dapui").float_element("watches", float_params)
  --       end,
  --       desc = "Open Floating Watches", mode = {"n", "x"} },
  --     { "<leader>dfb",
  --       function()
  --         require("dapui").float_element("breakpoints", float_params)
  --       end,
  --       desc = "Open Floating Breakpoints", mode = {"n", "x"} },
  --     { "<leader>dfr",
  --       function()
  --         require("dapui").float_element("repl", float_params)
  --       end,
  --       desc = "Open Floating Repl", mode = {"n", "x"} },
  --     { "<leader>dfc",
  --       function()
  --         require("dapui").float_element("console", float_params)
  --       end,
  --       desc = "Open Floating Console", mode = {"n", "x"} },
  --   },
  -- opts = {
  --   layouts = {
  --     {
  --       elements = {
  --         {
  --           id = "scopes",
  --           size = 0.25,
  --         },
  --         { id = "breakpoints", size = 0.25 },
  --         { id = "stacks", size = 0.25 },
  --         { id = "watches", size = 0.25 },
  --       },
  --       size = 40,
  --       position = "left",
  --     },
  --     {
  --       elements = {
  --         "repl",
  --         "console",
  --       },
  --       size = 10,
  --       position = "bottom",
  --     },
  --   },
  -- },
  -- config = function(_, opts)
  --   local dap = require("dap")
  --   local dapui = require("dapui")
  --   dapui.setup(opts)
  --   dap.listeners.after.event_initialized["dapui_config"] = function()
  --     dapui.open({})
  --   end
  --   dap.listeners.before.event_terminated["dapui_config"] = function()
  --     dapui.close({})
  --   end
  --   dap.listeners.before.event_exited["dapui_config"] = function()
  --     dapui.close({})
  --   end
  -- end,
}
