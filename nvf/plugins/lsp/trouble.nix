{ ... }:
{
  vim.lsp.trouble = {
    enable = true;

    mappings = {
      workspaceDiagnostics = null;
      documentDiagnostics = null;
      lspReferences = null;
      quickfix = null;
      locList = null;
      symbols = null;
    };
  };

  vim.keymaps = [
    {
      key = "<leader>xx";
      mode = "n";
      action = "<cmd>Trouble diagnostics toggle<CR>";
      desc = "Diagnostics (Trouble)";
    }
    {
      key = "<leader>xX";
      mode = "n";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
      desc = "Buffer Diagnostics (Trouble)";
    }
    {
      key = "<leader>xs";
      mode = "n";
      action = "<cmd>Trouble symbols toggle<CR>";
      desc = "Symbols (Trouble)";
    }
    {
      key = "<leader>xS";
      mode = "n";
      action = "<cmd>Trouble lsp toggle<CR>";
      desc = "LSP references/definitions/... (Trouble)";
    }
    {
      key = "<leader>xL";
      mode = "n";
      action = "<cmd>Trouble loclist toggle<CR>";
      desc = "Location List (Trouble)";
    }
    {
      key = "<leader>xQ";
      mode = "n";
      action = "<cmd>Trouble qflist toggle<CR>";
      desc = "Quickfix List (Trouble)";
    }
  ];
}
