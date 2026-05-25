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
        "v"
      ];
      action.__raw = ''
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end
      '';
      options.desc = "Format buffer";
    }
  ];
}
