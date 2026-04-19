{ ... }:
{
  vim.keymaps = [
    {
      key = "<leader>ss";
      mode = [ "n" ];
      action = "function() require('snacks').picker.lsp_symbols() end";
      lua = true;
      desc = "LSP Symbols";
    }
    {
      key = "<leader>sS";
      mode = [ "n" ];
      action = "function() require('snacks').picker.lsp_workspace_symbols() end";
      lua = true;
      desc = "LSP Workspace Symbols";
    }
    {
      key = "gai";
      mode = [ "n" ];
      action = "function() require('snacks').picker.lsp_incoming_calls() end";
      lua = true;
      desc = "Calls Incoming";
    }
    {
      key = "gao";
      mode = [ "n" ];
      action = "function() require('snacks').picker.lsp_outgoing_calls() end";
      lua = true;
      desc = "Calls Outgoing";
    }
    {
      key = "gd";
      mode = [ "n" ];
      action = "function() require('snacks').picker.lsp_definitions() end";
      lua = true;
      desc = "Goto Definition";
    }
    {
      key = "gr";
      mode = [ "n" ];
      action = "function() require('snacks').picker.lsp_references() end";
      lua = true;
      desc = "References";
    }
    {
      key = "gI";
      mode = [ "n" ];
      action = "function() require('snacks').picker.lsp_implementations() end";
      lua = true;
      desc = "Goto Implementation";
    }
    {
      key = "gy";
      mode = [ "n" ];
      action = "function() require('snacks').picker.lsp_type_definitions() end";
      lua = true;
      desc = "Goto Type Definition";
    }
    {
      key = "<a-n>";
      mode = [ "n" ];
      action = "function() require('snacks').words.jump(vim.v.count1, true) end";
      lua = true;
      desc = "Next Reference";
    }
    {
      key = "<a-p>";
      mode = [ "n" ];
      action = "function() require('snacks').words.jump(-vim.v.count1, true) end";
      lua = true;
      desc = "Prev Reference";
    }
  ];
}
