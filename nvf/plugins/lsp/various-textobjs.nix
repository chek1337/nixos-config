{ pkgs, ... }:
{
  vim = {
    extraPlugins = with pkgs.vimPlugins; {
      nvim-various-textobjs = {
        package = nvim-various-textobjs;
        setup = ''
          require("various-textobjs").setup({
            keymaps = {
              useDefaults = true,
              disabledDefaults = { "r", "R", "n" },
            },
          })
        '';
      };
    };

    keymaps = [
      {
        key = "gR";
        mode = [
          "o"
          "x"
        ];
        action = "function() require('various-textobjs').restOfIndentation() end";
        lua = true;
        desc = "restOfIndentation textobj";
      }
    ];
  };
}
