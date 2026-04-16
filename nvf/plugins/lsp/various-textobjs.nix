{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    nvim-various-textobjs = {
      package = nvim-various-textobjs;
      setup = ''
        require("various-textobjs").setup({
          keymaps = {
            useDefaults = true,
            -- "n" конфликтует с vim search-next в o-режиме
            disabledDefaults = { "n" },
          },
        })
      '';
    };
  };
}
