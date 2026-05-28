{ ... }:
{
  plugins.persistence = {
    enable = true;
    # DeferredUIEnter нужен, чтобы persistence успел повесить VimLeavePre
    # для автосейва. Но между UIEnter и schedule-фазой есть окно, в котором
    # юзер может уже кликнуть на snacks-dashboard или нажать <leader>S* — для
    # таких action'ов внизу явный trigger_load.
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
      action = "<cmd>lua require('lz.n').trigger_load('persistence.nvim'); require('persistence').load()<cr>";
      options.desc = "Restore session (CWD)";
    }
    {
      key = "<leader>Sl";
      mode = "n";
      action = "<cmd>lua require('lz.n').trigger_load('persistence.nvim'); require('persistence').load({ last = true })<cr>";
      options.desc = "Restore last session";
    }
    {
      key = "<leader>Sd";
      mode = "n";
      action = "<cmd>lua require('lz.n').trigger_load('persistence.nvim'); require('persistence').stop()<cr>";
      options.desc = "Stop session saving";
    }
  ];
}
