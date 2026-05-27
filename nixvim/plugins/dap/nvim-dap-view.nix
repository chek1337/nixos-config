{ ... }:
{
  plugins.dap-view = {
    enable = true;

    settings = {
      winbar = {
        sections = [
          "watches"
          "scopes"
          "breakpoints"
          "repl"
          "exceptions"
          "threads"
          "sessions"
        ];
        controls = {
          enabled = true;
          position = "right";
        };
      };
      windows = {
        size = 0.35;
        position = "right";
        terminal = {
          size = 0.45;
          position = "below";
        };
      };
      auto_toggle = true;
    };
  };

  keymaps = [
    {
      key = "<leader>dd";
      mode = "n";
      action = "<cmd>DapViewToggle!<cr>";
      options.desc = "Debug: Toggle dap-view";
    }
    {
      key = "<leader>dx";
      mode = "n";
      action = "<cmd>DapViewClose!<cr>";
      options.desc = "Debug: Close dap-view force";
    }
    {
      key = "<leader>dw";
      mode = "n";
      action = "<cmd>DapViewWatch<cr>";
      options.desc = "Debug: Add Variable to Scope";
    }
  ];
}
