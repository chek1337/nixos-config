{ ... }:
{
  keymaps = [
    {
      key = "<leader>ss";
      mode = "n";
      action.__raw = "function() require('snacks').picker.lsp_symbols() end";
      options.desc = "LSP Symbols";
    }
    {
      key = "<leader>sS";
      mode = "n";
      action.__raw = "function() require('snacks').picker.lsp_workspace_symbols() end";
      options.desc = "LSP Workspace Symbols";
    }
    {
      key = "gai";
      mode = "n";
      action.__raw = "function() require('snacks').picker.lsp_incoming_calls() end";
      options.desc = "Calls Incoming";
    }
    {
      key = "gao";
      mode = "n";
      action.__raw = "function() require('snacks').picker.lsp_outgoing_calls() end";
      options.desc = "Calls Outgoing";
    }
    {
      key = "gd";
      mode = "n";
      action.__raw = "function() require('snacks').picker.lsp_definitions() end";
      options.desc = "Goto Definition";
    }
    {
      key = "gr";
      mode = "n";
      action.__raw = "function() require('snacks').picker.lsp_references() end";
      options.desc = "References";
    }
    {
      key = "gI";
      mode = "n";
      action.__raw = "function() require('snacks').picker.lsp_implementations() end";
      options.desc = "Goto Implementation";
    }
    {
      key = "gy";
      mode = "n";
      action.__raw = "function() require('snacks').picker.lsp_type_definitions() end";
      options.desc = "Goto Type Definition";
    }
    {
      key = "<a-n>";
      mode = "n";
      action.__raw = "function() require('snacks').words.jump(vim.v.count1, true) end";
      options.desc = "Next Reference";
    }
    {
      key = "<a-p>";
      mode = "n";
      action.__raw = "function() require('snacks').words.jump(-vim.v.count1, true) end";
      options.desc = "Prev Reference";
    }
    {
      key = "<leader>cR";
      mode = "n";
      action.__raw = # lua
        ''
          function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            for _, client in ipairs(clients) do
              if client:supports_method("workspace/willRenameFiles")
                or client:supports_method("workspace/didRenameFiles") then
                require('snacks').rename.rename_file()
                return
              end
            end
            vim.notify("LSP does not support file rename", vim.log.levels.WARN)
          end
        '';
      options.desc = "Rename File";
    }
  ];
}
