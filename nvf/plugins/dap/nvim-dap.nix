{ ... }:
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

    luaConfigRC.dap-signs = # lua
      ''
        vim.fn.sign_define("DapStopped", {
          text = "▶",
          texthl = "DiagnosticOk",
          linehl = "CursorLine",
          numhl = "DiagnosticOk",
        })
      '';
  };
}
