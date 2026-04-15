{ pkgs, ... }:
{
  vim = {
    extraPlugins = with pkgs.vimPlugins; {
      nvim-dap-view = {
        package = nvim-dap-view;
        setup = ''
          require("dap-view").setup({
            winbar = {
              sections = { "watches", "scopes", "breakpoints", "repl", "exceptions", "threads", "sessions" },
              controls = {
                enabled = true,
                position = "right",
              },
            },
            windows = {
              size = 0.35,
              position = "right",
              terminal = {
                size = 0.45,
                position = "below",
              },
            },
            auto_toggle = true,
          })
        '';
        after = [ "nvim-dap" ];
      };
    };

    keymaps = [
      {
        key = "<leader>dd";
        mode = "n";
        action = "<cmd>DapViewToggle!<cr>";
        desc = "Debug: Toggle dap-view";
      }
      {
        key = "<leader>dx";
        mode = "n";
        action = "<cmd>DapViewClose!<cr>";
        desc = "Debug: Close dap-view force";
      }
      {
        key = "<leader>dw";
        mode = "n";
        action = "<cmd>DapViewWatch<cr>";
        desc = "Debug: Add Variable to Scope";
      }
    ];
  };
}
