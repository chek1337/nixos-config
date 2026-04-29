{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    nvim-various-textobjs = {
      package = nvim-various-textobjs;
      setup = # lua
        ''
          require("various-textobjs").setup({
            keymaps = {
              useDefaults = true,
              -- "n" конфликтует с vim search-next в o-режиме
              -- "iS"/"aS" освобождаем — subword переезжает на "s"
              disabledDefaults = { "n", "iS", "aS" },
            },
          })

          -- Меняем местами s (vim sentence) и S (subword)
          local map = vim.keymap.set
          map({ "o", "x" }, "is", "<cmd>lua require('various-textobjs').subword('inner')<CR>", { desc = "inner subword textobj" })
          map({ "o", "x" }, "as", "<cmd>lua require('various-textobjs').subword('outer')<CR>", { desc = "outer subword textobj" })
          map({ "o", "x" }, "iS", "is", { remap = false, desc = "inner sentence textobj" })
          map({ "o", "x" }, "aS", "as", { remap = false, desc = "outer sentence textobj" })
        '';
    };
  };
}
