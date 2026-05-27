{ pkgs, ... }:
let
  ox = [
    "o"
    "x"
  ];
in
{
  extraPlugins = [ pkgs.vimPlugins.nvim-various-textobjs ];

  extraConfigLua = ''
    require("various-textobjs").setup({
      keymaps = {
        useDefaults = true,
        -- "n" конфликтует с vim search-next в o-режиме
        -- "iS"/"aS" освобождаем — subword переезжает на "s"
        disabledDefaults = { "n", "iS", "aS" },
      },
    })
  '';

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
