{ ... }:
{
  plugins.dial.enable = true;

  extraConfigLua = ''
    do
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.constant.alias.bool,
          augend.constant.alias.Bool,
          augend.integer.alias.hex,
        },
      })
    end
  '';

  keymaps = [
    {
      key = "<C-a>";
      mode = "n";
      action.__raw = "function() require('dial.map').manipulate('increment', 'normal') end";
      options.desc = "Increment";
    }
    {
      key = "<C-x>";
      mode = "n";
      action.__raw = "function() require('dial.map').manipulate('decrement', 'normal') end";
      options.desc = "Decrement";
    }
    {
      key = "g<C-a>";
      mode = "n";
      action.__raw = "function() require('dial.map').manipulate('increment', 'gnormal') end";
      options.desc = "Increment (additive)";
    }
    {
      key = "g<C-x>";
      mode = "n";
      action.__raw = "function() require('dial.map').manipulate('decrement', 'gnormal') end";
      options.desc = "Decrement (additive)";
    }
    {
      key = "<C-a>";
      mode = "x";
      action.__raw = "function() require('dial.map').manipulate('increment', 'visual') end";
      options.desc = "Increment";
    }
    {
      key = "<C-x>";
      mode = "x";
      action.__raw = "function() require('dial.map').manipulate('decrement', 'visual') end";
      options.desc = "Decrement";
    }
    {
      key = "g<C-a>";
      mode = "x";
      action.__raw = "function() require('dial.map').manipulate('increment', 'gvisual') end";
      options.desc = "Increment (additive)";
    }
    {
      key = "g<C-x>";
      mode = "x";
      action.__raw = "function() require('dial.map').manipulate('decrement', 'gvisual') end";
      options.desc = "Decrement (additive)";
    }
  ];
}
