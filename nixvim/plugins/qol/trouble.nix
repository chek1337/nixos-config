{ ... }:
{
  plugins.trouble = {
    enable = true;
    lazyLoad.settings.cmd = "Trouble";
  };

  keymaps = [
    {
      key = "<leader>xx";
      mode = "n";
      action = "<cmd>Trouble diagnostics toggle<CR>";
      options.desc = "Diagnostics (Trouble)";
    }
    {
      key = "<leader>xX";
      mode = "n";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
      options.desc = "Buffer Diagnostics (Trouble)";
    }
    {
      key = "<leader>xs";
      mode = "n";
      action = "<cmd>Trouble symbols toggle<CR>";
      options.desc = "Symbols (Trouble)";
    }
    {
      key = "<leader>xS";
      mode = "n";
      action = "<cmd>Trouble lsp toggle<CR>";
      options.desc = "LSP references/definitions/... (Trouble)";
    }
    {
      key = "<leader>xL";
      mode = "n";
      action = "<cmd>Trouble loclist toggle<CR>";
      options.desc = "Location List (Trouble)";
    }
    {
      key = "<leader>xQ";
      mode = "n";
      action = "<cmd>Trouble qflist toggle<CR>";
      options.desc = "Quickfix List (Trouble)";
    }
  ];
}
