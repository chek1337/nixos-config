{ ... }:
{
  plugins.noice = {
    enable = true;
    settings.routes = [
      {
        filter = {
          event = "msg_show";
          any = [
            { find = "%d+L, %d+B"; }
            { find = "; after #%d+"; }
            { find = "; before #%d+"; }
          ];
        };
        view = "mini";
      }
    ];
  };

  keymaps = [
    {
      key = "<S-Enter>";
      mode = "c";
      action.__raw = "function() require('noice').redirect(vim.fn.getcmdline()) end";
      options.desc = "Redirect Cmdline";
    }
    {
      key = "<leader>snl";
      mode = "n";
      action.__raw = "function() require('noice').cmd('last') end";
      options.desc = "Noice Last Message";
    }
    {
      key = "<leader>snh";
      mode = "n";
      action.__raw = "function() require('noice').cmd('history') end";
      options.desc = "Noice History";
    }
    {
      key = "<leader>sna";
      mode = "n";
      action.__raw = "function() require('noice').cmd('all') end";
      options.desc = "Noice All";
    }
    {
      key = "<leader>snd";
      mode = "n";
      action.__raw = "function() require('noice').cmd('dismiss') end";
      options.desc = "Dismiss All";
    }
    {
      key = "<C-f>";
      mode = [
        "i"
        "n"
        "s"
      ];
      action.__raw = "function() if not require('noice.lsp').scroll(4) then return '<C-f>' end end";
      options = {
        expr = true;
        silent = true;
        desc = "Scroll Forward (LSP docs)";
      };
    }
    {
      key = "<C-b>";
      mode = [
        "i"
        "n"
        "s"
      ];
      action.__raw = "function() if not require('noice.lsp').scroll(-4) then return '<C-b>' end end";
      options = {
        expr = true;
        silent = true;
        desc = "Scroll Backward (LSP docs)";
      };
    }
  ];
}
