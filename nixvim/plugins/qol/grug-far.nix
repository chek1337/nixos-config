{ ... }:
{
  plugins.grug-far = {
    enable = true;
    settings = {
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
      action.__raw = ''
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
      options.desc = "Search and Replace in Project";
    }
    {
      key = "<leader>srf";
      mode = [
        "n"
        "x"
      ];
      action.__raw = "function() require('grug-far').open({ prefills = { paths = vim.fn.expand('%') } }) end";
      options.desc = "Search and Replace in File";
    }
    {
      key = "<leader>srv";
      mode = [
        "n"
        "x"
      ];
      action.__raw = "function() require('grug-far').open({ visualSelectionUsage = 'operate-within-range' }) end";
      options.desc = "Search and Replace for Current Visual Selection";
    }
  ];
}
