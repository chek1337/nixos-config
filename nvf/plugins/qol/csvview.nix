{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    csvview-nvim = {
      package = csvview-nvim;
      setup = # lua
        ''
          require("csvview").setup({
            view = {
              display_mode = "border",
              sticky_header = {
                enabled = true,
              },
            },
            keymaps = {
              textobject_field_inner = { "if", mode = { "o", "x" } },
              textobject_field_outer = { "af", mode = { "o", "x" } },
              jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
              jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
              jump_next_row = { "<Enter>", mode = { "n", "v" } },
              jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
            },
          })
          vim.api.nvim_create_autocmd("FileType", {
            pattern = { "csv", "tsv" },
            callback = function()
              vim.cmd("CsvViewEnable")
            end,
          })
        '';
    };
  };
}
