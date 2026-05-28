{ ... }:
{
  plugins.todo-comments = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
  };

  keymaps = [
    {
      key = "]t";
      mode = "n";
      action.__raw = "function() require('todo-comments').jump_next() end";
      options.desc = "Next Todo Comment";
    }
    {
      key = "[t";
      mode = "n";
      action.__raw = "function() require('todo-comments').jump_prev() end";
      options.desc = "Previous Todo Comment";
    }
    {
      key = "<leader>xt";
      mode = "n";
      action = "<cmd>Trouble todo toggle<CR>";
      options.desc = "Todo (Trouble)";
    }
    {
      key = "<leader>xT";
      mode = "n";
      action = "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<CR>";
      options.desc = "Todo/Fix/Fixme (Trouble)";
    }
    {
      key = "<leader>st";
      mode = "n";
      action.__raw = "function() require('snacks').picker.todo_comments() end";
      options.desc = "Todo";
    }
    {
      key = "<leader>sT";
      mode = "n";
      action.__raw = "function() require('snacks').picker.todo_comments({ keywords = { 'TODO', 'FIX', 'FIXME' } }) end";
      options.desc = "Todo/Fix/Fixme";
    }
  ];
}
