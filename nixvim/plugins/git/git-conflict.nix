{ ... }:
{
  plugins.git-conflict = {
    enable = true;
    lazyLoad.settings.event = [
      "BufReadPost"
      "BufNewFile"
    ];
  };

  keymaps = [
    {
      key = "<leader>gCq";
      mode = "n";
      action = "<cmd>GitConflictListQf<cr>";
      options.desc = "List Conflicts (Quickfix)";
    }
    {
      key = "<leader>gCr";
      mode = "n";
      action = "<cmd>GitConflictRefresh<cr>";
      options.desc = "Refresh Conflicts";
    }
    {
      key = "<leader>gCc";
      mode = "n";
      action = "<cmd>GitConflictChooseOurs<cr>";
      options.desc = "Choose Current (HEAD)";
    }
    {
      key = "<leader>gCi";
      mode = "n";
      action = "<cmd>GitConflictChooseTheirs<cr>";
      options.desc = "Choose Incoming";
    }
    {
      key = "<leader>gCb";
      mode = "n";
      action = "<cmd>GitConflictChooseBoth<cr>";
      options.desc = "Choose Both";
    }
    {
      key = "<leader>gCn";
      mode = "n";
      action = "<cmd>GitConflictChooseNone<cr>";
      options.desc = "Choose None";
    }
  ];
}
