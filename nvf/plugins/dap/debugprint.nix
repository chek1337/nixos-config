{ pkgs, ... }:
{
  vim = {
    extraPlugins = {
      debugprint-nvim = {
        package = pkgs.vimPlugins.debugprint-nvim;
        setup = # lua
          ''
            require("debugprint").setup({
              keymaps = {
                normal = {
                  plain_below = "g?p",
                  plain_above = "g?P",
                  variable_below = "g?v",
                  variable_above = "g?V",
                  variable_below_alwaysprompt = "",
                  variable_above_alwaysprompt = "",
                  surround_plain = "g?sp",
                  surround_variable = "g?sv",
                  surround_variable_alwaysprompt = "",
                  textobj_below = "g?o",
                  textobj_above = "g?O",
                  textobj_surround = "g?so",
                  toggle_comment_debug_prints = "",
                  delete_debug_prints = "",
                },
                visual = {
                  variable_below = "g?v",
                  variable_above = "g?V",
                },
              },
            })
          '';
      };
    };

    keymaps = [
      {
        key = "<leader>dpd";
        mode = "n";
        action = "<cmd>Debugprint delete<cr>";
        desc = "Debug: Delete all debug prints";
      }
      {
        key = "<leader>dpc";
        mode = "n";
        action = "<cmd>Debugprint commenttoggle<cr>";
        desc = "Debug: Toggle comment debug prints";
      }
      {
        key = "<leader>dpr";
        mode = "n";
        action = "<cmd>Debugprint resetcounter<cr>";
        desc = "Debug: Reset counter";
      }
      {
        key = "<leader>dps";
        mode = "n";
        action = "<cmd>Debugprint search<cr>";
        desc = "Debug: Search debug prints";
      }
      {
        key = "<leader>dpq";
        mode = "n";
        action = "<cmd>Debugprint qflist<cr>";
        desc = "Debug: Debug prints → quickfix";
      }
    ];
  };
}
