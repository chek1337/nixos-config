{ ... }:
{
  plugins.dap = {
    enable = true;
    lazyLoad.settings = {
      event = "DeferredUIEnter";
      # nixvim инжектит `require("dap-python").setup(...)` в наш after-хук
      # (у dap-python `callSetup = false`). Поднимаем dap-python в rtp ДО того,
      # как dap отработает after, иначе require падает: модуль ещё в pack/opt/.
      before.__raw = "function() require('lz.n').trigger_load('nvim-dap-python') end";
    };

    signs = {
      dapBreakpoint = {
        text = "🛑";
        texthl = "ErrorMsg";
      };
      dapStopped = {
        text = "▶";
        texthl = "DiagnosticOk";
        linehl = "CursorLine";
        numhl = "DiagnosticOk";
      };
    };

    # gdb's native DAP server (gdb >= 14). Pairs reliably with gcc-built
    # binaries, unlike lldb on gcc-flavoured DWARF. `gdb` is resolved from
    # PATH — run nvim from the project devshell (direnv) so it's present.
    adapters.executables.gdb = {
      command = "gdb";
      args = [
        "--interpreter=dap"
        "--eval-command"
        "set print pretty on"
      ];
    };
  };

  keymaps = [
    {
      key = "<F5>";
      mode = "n";
      action.__raw = "function() require('dap').continue() end";
      options.desc = "Debug: Continue";
    }
    {
      key = "<F17>"; # Shift+F5
      mode = "n";
      action.__raw = "function() require('dap').terminate() end";
      options.desc = "Debug: Terminate";
    }
    {
      key = "<F41>"; # Ctrl+Shift+F5
      mode = "n";
      action.__raw = "function() require('dap').restart() end";
      options.desc = "Debug: Restart";
    }
    {
      key = "<leader>dl";
      mode = "n";
      action.__raw = "function() require('dap').run_last() end";
      options.desc = "Debug: Run Last";
    }
    {
      key = "<leader>dr";
      mode = "n";
      action.__raw = "function() require('dap').repl.toggle() end";
      options.desc = "Debug: Toggle REPL";
    }
    {
      key = "<leader>dW";
      mode = "n";
      action.__raw = "function() require('dap.ui.widgets').hover() end";
      options.desc = "Debug: Hover";
    }
    {
      key = "<F8>";
      mode = "n";
      action.__raw = "function() require('dap').run_to_cursor() end";
      options.desc = "Debug: Run to Cursor";
    }
    {
      key = "<F10>";
      mode = "n";
      action.__raw = "function() require('dap').step_over() end";
      options.desc = "Debug: Step Over";
    }
    {
      key = "<F11>";
      mode = "n";
      action.__raw = "function() require('dap').step_into() end";
      options.desc = "Debug: Step Into";
    }
    {
      key = "<F23>"; # Shift+F11
      mode = "n";
      action.__raw = "function() require('dap').step_out() end";
      options.desc = "Debug: Step Out";
    }
    {
      key = "<leader>dgk";
      mode = "n";
      action.__raw = "function() require('dap').step_back() end";
      options.desc = "Debug: Step Back";
    }
    {
      key = "<leader>dk";
      mode = "n";
      action.__raw = "function() require('dap').up() end";
      options.desc = "Debug: Go Up Stack";
    }
    {
      key = "<leader>dj";
      mode = "n";
      action.__raw = "function() require('dap').down() end";
      options.desc = "Debug: Go Down Stack";
    }
  ];
}
