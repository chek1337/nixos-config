{ ... }:
{
  vim = {
    ui = {
      # borders.enable = true;
      # colorizer.enable = true;

      noice = {
        enable = true;
        setupOpts.routes = [
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
    };

    keymaps = [
      {
        key = "<S-Enter>";
        mode = [ "c" ];
        action = "function() require('noice').redirect(vim.fn.getcmdline()) end";
        lua = true;
        desc = "Redirect Cmdline";
      }
      {
        key = "<leader>snl";
        mode = [ "n" ];
        action = "function() require('noice').cmd('last') end";
        lua = true;
        desc = "Noice Last Message";
      }
      {
        key = "<leader>snh";
        mode = [ "n" ];
        action = "function() require('noice').cmd('history') end";
        lua = true;
        desc = "Noice History";
      }
      {
        key = "<leader>sna";
        mode = [ "n" ];
        action = "function() require('noice').cmd('all') end";
        lua = true;
        desc = "Noice All";
      }
      {
        key = "<leader>snd";
        mode = [ "n" ];
        action = "function() require('noice').cmd('dismiss') end";
        lua = true;
        desc = "Dismiss All";
      }
      {
        key = "<C-f>";
        mode = [
          "i"
          "n"
          "s"
        ];
        action = "function() if not require('noice.lsp').scroll(4) then return '<C-f>' end end";
        lua = true;
        expr = true;
        silent = true;
        desc = "Scroll Forward (LSP docs)";
      }
      {
        key = "<C-b>";
        mode = [
          "i"
          "n"
          "s"
        ];
        action = "function() if not require('noice.lsp').scroll(-4) then return '<C-b>' end end";
        lua = true;
        expr = true;
        silent = true;
        desc = "Scroll Backward (LSP docs)";
      }
    ];
  };
}
