return {
  "monaqa/dial.nvim",
  keys = {
    { "<C-a>", function() require("dial.map").manipulate("increment", "normal") end, mode = "n" },
    { "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, mode = "n" },
    { "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end, mode = "n" },
    { "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, mode = "n" },
    { "<C-a>", function() require("dial.map").manipulate("increment", "visual") end, mode = "x" },
    { "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end, mode = "x" },
    { "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end, mode = "x" },
    { "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, mode = "x" },
  },
  config = function()
    local augend = require("dial.augend")
    require("dial.config").augends:register_group({
      default = {
        augend.integer.alias.decimal,
        augend.constant.alias.bool,
        augend.constant.alias.Bool,
        augend.integer.alias.hex,
      },
    })
  end,
}
