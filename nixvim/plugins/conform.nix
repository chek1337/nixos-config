{ ... }:
{
  plugins.conform-nvim = {
    enable = true;
    settings = {
      notify_on_error = true;
      formatters_by_ft = { };
    };
  };

  keymaps = [
    {
      key = "<leader>cf";
      mode = "n";
      action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<cr>";
      options.desc = "Format document";
    }
    {
      key = "<leader>cF";
      mode = [
        "n"
        "x"
      ];
      action.__raw = "function() require('conform').format({ formatters = { 'injected' }, timeout_ms = 3000 }) end";
      options.desc = "Format Injected Langs";
    }
    {
      key = "<leader>cf";
      mode = "v";
      action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true, range = { [\"start\"] = vim.api.nvim_buf_get_mark(0, \"<\"), [\"end\"] = vim.api.nvim_buf_get_mark(0, \">\") } })<cr>";
      options.desc = "Format selection";
    }
  ];
}
