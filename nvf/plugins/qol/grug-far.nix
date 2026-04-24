{ ... }:
{
  vim = {
    utility.grug-far-nvim = {
      enable = true;
      setupOpts = {
        headerMaxWidth = 80;
        enabledEngines = [
          "ripgrep"
          "astgrep"
        ];
        startInInsertMode = false;
      };
    };

    keymaps = [
      {
        key = "<leader>srr";
        mode = [
          "n"
          "x"
        ];
        action = ''
          function()
            local grug = require("grug-far")
            local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
            grug.open({
              transient = true,
              prefills = {
                filesFilter = ext and ext ~= "" and "*." .. ext or nil,
              },
            })
          end
        '';
        lua = true;
        desc = "Search and Replace in Project";
      }
      {
        key = "<leader>srf";
        mode = [
          "n"
          "x"
        ];
        action = "function() require('grug-far').open({ prefills = { paths = vim.fn.expand('%') } }) end";
        lua = true;
        desc = "Search and Replace in File";
      }
      {
        key = "<leader>srv";
        mode = [
          "n"
          "x"
        ];
        action = "function() require('grug-far').open({ visualSelectionUsage = 'operate-within-range' }) end";
        lua = true;
        desc = "Search and Replace for Current Visual Selection";
      }
    ];
  };
}
