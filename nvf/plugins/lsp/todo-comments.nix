{ ... }:
{
  vim.notes.todo-comments = {
    enable = true;

    mappings = {
      quickFix = null;
      telescope = null;
      trouble = null;
    };
  };

  vim.keymaps = [
    {
      key = "]t";
      mode = "n";
      lua = true;
      action = ''function() require("todo-comments").jump_next() end'';
      desc = "Next Todo Comment";
    }
    {
      key = "[t";
      mode = "n";
      lua = true;
      action = ''function() require("todo-comments").jump_prev() end'';
      desc = "Previous Todo Comment";
    }
    {
      key = "<leader>xt";
      mode = "n";
      action = "<cmd>Trouble todo toggle<CR>";
      desc = "Todo (Trouble)";
    }
    {
      key = "<leader>xT";
      mode = "n";
      action = "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<CR>";
      desc = "Todo/Fix/Fixme (Trouble)";
    }
    {
      key = "<leader>st";
      mode = "n";
      action = "<cmd>TodoTelescope<CR>";
      desc = "Todo";
    }
    {
      key = "<leader>sT";
      mode = "n";
      action = "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<CR>";
      desc = "Todo/Fix/Fixme";
    }
  ];
}
