{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    persistence-nvim = {
      package = persistence-nvim;
      setup = ''
        require("persistence").setup({
          dir = vim.fn.stdpath("data") .. "/sessions/",
          options = { "buffers", "curdir", "tabpages", "winsize", "skiprtp" },
          pre_save = nil,
        })
      '';
    };
  };

  vim.keymaps = [
    {
      key = "<leader>ss";
      mode = "n";
      action = "<cmd>lua require('persistence').load()<cr>";
      desc = "Restore session (CWD)";
    }
    {
      key = "<leader>sl";
      mode = "n";
      action = "<cmd>lua require('persistence').load({ last = true })<cr>";
      desc = "Restore last session";
    }
    {
      key = "<leader>sd";
      mode = "n";
      action = "<cmd>lua require('persistence').stop()<cr>";
      desc = "Stop session saving";
    }
  ];
}
