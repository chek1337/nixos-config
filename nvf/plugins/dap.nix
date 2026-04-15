{ pkgs, ... }:
{
  vim = {
    debugger.nvim-dap = {
      enable = true;
      ui.enable = false;

      mappings = {
        continue = "<F5>";
        terminate = "<F17>"; # Shift+F5
        restart = "<F41>"; # Ctrl+Shift+F5
        runLast = "<leader>dl";
        toggleRepl = "<leader>dr";
        hover = "<leader>dW";
        runToCursor = "<F8>";
        stepOver = "<F10>";
        stepInto = "<F11>";
        stepOut = "<F23>"; # Shift+F11
        stepBack = "<leader>dgk";
        goUp = "<leader>dk";
        goDown = "<leader>dj";
        toggleDapUI = "<leader>du";
      };
    };

    extraPlugins = with pkgs.vimPlugins; {
      nvim-dap-python = {
        package = nvim-dap-python;
        setup = ''require("dap-python").setup("debugpy-adapter")'';
        after = [ "nvim-dap" ];
      };

      nvim-dap-virtual-text = {
        package = nvim-dap-virtual-text;
        setup = ''
          require("nvim-dap-virtual-text").setup({
            display_callback = function(variable, buf, stackframe, node, options)
              local val = variable.value:gsub("%s+", " ")
              if #val > 40 then val = val:sub(1, 20) .. "…" .. val:sub(-20) end
              if options.virt_text_pos == "inline" then
                return " = " .. val
              else
                return variable.name .. " = " .. val
              end
            end,
          })
        '';
        after = [ "nvim-dap" ];
      };

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
      # persistent-breakpoints заменяют стандартный F9
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

      # nvim-dap-view
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
