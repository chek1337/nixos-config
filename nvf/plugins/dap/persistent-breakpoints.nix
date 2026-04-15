{ pkgs, ... }:
{
  vim = {
    extraPlugins = with pkgs.vimPlugins; {
      persistent-breakpoints = {
        package = persistent-breakpoints-nvim;
        after = [ "nvim-dap" ];
        setup = ''
          require("persistent-breakpoints").setup({
            save_dir = vim.fn.stdpath("data") .. "/nvim_checkpoints",
            load_breakpoints_event = { "BufReadPost" },
            always_reload = true,
          })
          -- BufReadPost уже отработал к моменту загрузки плагина,
          -- вручную инициализируем bps для текущего буфера
          require("persistent-breakpoints.api").load_breakpoints()
        '';
      };
    };

    keymaps = [
      {
        key = "<F9>";
        mode = "n";
        action = "<cmd>lua require('persistent-breakpoints.api').toggle_breakpoint()<cr>";
        desc = "Debug: Toggle Breakpoint (F9)";
      }
      {
        key = "<F21>"; # Shift+F9
        mode = "n";
        action = "<cmd>lua require('persistent-breakpoints.api').set_conditional_breakpoint()<cr>";
        desc = "Debug: Conditional Breakpoint";
      }
      {
        key = "<leader>dc";
        mode = "n";
        action = "<cmd>lua require('persistent-breakpoints.api').clear_all_breakpoints()<cr>";
        desc = "Debug: Clear All Breakpoints";
      }
    ];
  };
}
