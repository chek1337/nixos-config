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
      mode = [
        "n"
        "x"
      ];
      action.__raw = "function() require('conform').format({ async = true, lsp_fallback = true }) end";
      options.desc = "Format";
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
  ];
}
