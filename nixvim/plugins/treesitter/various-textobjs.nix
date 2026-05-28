{ pkgs, ... }:
let
  ox = [
    "o"
    "x"
  ];
in
{
  extraPlugins = [
    {
      plugin = pkgs.vimPlugins.nvim-various-textobjs;
      optional = true;
    }
  ];

  plugins.lz-n.plugins = [
    {
      __unkeyed-1 = "nvim-various-textobjs";
      event = "BufReadPost";
      after = # lua
        ''
          function()
            require("various-textobjs").setup({
              keymaps = {
                useDefaults = true,
                -- "n" конфликтует с vim search-next в o-режиме
                -- "iS"/"aS" освобождаем — subword переезжает на "s"
                disabledDefaults = { "n", "iS", "aS" },
              },
            })
          end
        '';
    }
  ];

  keymaps = [
    {
      key = "is";
      mode = ox;
      action = "<cmd>lua require('various-textobjs').subword('inner')<CR>";
      options.desc = "inner subword textobj";
    }
    {
      key = "as";
      mode = ox;
      action = "<cmd>lua require('various-textobjs').subword('outer')<CR>";
      options.desc = "outer subword textobj";
    }
    {
      key = "iS";
      mode = ox;
      action = "is";
      options.desc = "inner sentence textobj";
    }
    {
      key = "aS";
      mode = ox;
      action = "as";
      options.desc = "outer sentence textobj";
    }
  ];
}
