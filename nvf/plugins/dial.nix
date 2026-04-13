{ pkgs, ... }:
{
  vim = {
    extraPlugins = with pkgs.vimPlugins; {
      dial-nvim = {
        package = dial-nvim;
        setup = ''
          local augend = require("dial.augend")
          require("dial.config").augends:register_group({
            default = {
              augend.integer.alias.decimal,
              augend.constant.alias.bool,
              augend.constant.alias.Bool,
              augend.integer.alias.hex,
            },
          })
        '';
      };
    };

    keymaps = [
      {
        key = "<C-a>";
        mode = [ "n" ];
        action = "function() require('dial.map').manipulate('increment', 'normal') end";
        lua = true;
        desc = "Increment";
      }
      {
        key = "<C-x>";
        mode = [ "n" ];
        action = "function() require('dial.map').manipulate('decrement', 'normal') end";
        lua = true;
        desc = "Decrement";
      }
      {
        key = "g<C-a>";
        mode = [ "n" ];
        action = "function() require('dial.map').manipulate('increment', 'gnormal') end";
        lua = true;
        desc = "Increment (additive)";
      }
      {
        key = "g<C-x>";
        mode = [ "n" ];
        action = "function() require('dial.map').manipulate('decrement', 'gnormal') end";
        lua = true;
        desc = "Decrement (additive)";
      }
      {
        key = "<C-a>";
        mode = [ "x" ];
        action = "function() require('dial.map').manipulate('increment', 'visual') end";
        lua = true;
        desc = "Increment";
      }
      {
        key = "<C-x>";
        mode = [ "x" ];
        action = "function() require('dial.map').manipulate('decrement', 'visual') end";
        lua = true;
        desc = "Decrement";
      }
      {
        key = "g<C-a>";
        mode = [ "x" ];
        action = "function() require('dial.map').manipulate('increment', 'gvisual') end";
        lua = true;
        desc = "Increment (additive)";
      }
      {
        key = "g<C-x>";
        mode = [ "x" ];
        action = "function() require('dial.map').manipulate('decrement', 'gvisual') end";
        lua = true;
        desc = "Decrement (additive)";
      }
    ];
  };
}
