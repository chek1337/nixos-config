{ ... }:
{
  plugins.persistence = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
    settings = {
      dir.__raw = ''vim.fn.stdpath("data") .. "/sessions/"'';
      options = [
        "buffers"
        "curdir"
        "tabpages"
        "winsize"
        "skiprtp"
      ];
    };
  };

  keymaps = [
    {
      key = "<leader>Ss";
      mode = "n";
      action = "<cmd>lua require('persistence').load()<cr>";
      options.desc = "Restore session (CWD)";
    }
    {
      key = "<leader>Sl";
      mode = "n";
      action = "<cmd>lua require('persistence').load({ last = true })<cr>";
      options.desc = "Restore last session";
    }
    {
      key = "<leader>Sd";
      mode = "n";
      action = "<cmd>lua require('persistence').stop()<cr>";
      options.desc = "Stop session saving";
    }
  ];
}
