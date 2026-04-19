{ ... }:
{
  vim.utility.snacks-nvim.setupOpts = {
    toggle.enable = true;
    zen.enable = true;
    dim.enable = true;
  };

  vim.keymaps = [
    {
      key = "<leader>us";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.option('spell', { name = 'Spelling' }):toggle() end";
      lua = true;
      desc = "Toggle Spelling";
    }
    {
      key = "<leader>uw";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.option('wrap', { name = 'Wrap' }):toggle() end";
      lua = true;
      desc = "Toggle Wrap";
    }
    {
      key = "<leader>uL";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.option('relativenumber', { name = 'Relative Number' }):toggle() end";
      lua = true;
      desc = "Toggle Relative Number";
    }
    {
      key = "<leader>uc";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = 'Conceal Level' }):toggle() end";
      lua = true;
      desc = "Toggle Conceal Level";
    }
    {
      key = "<leader>uA";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.option('showtabline', { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = 'Tabline' }):toggle() end";
      lua = true;
      desc = "Toggle Tabline";
    }
    {
      key = "<leader>ub";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):toggle() end";
      lua = true;
      desc = "Toggle Background";
    }
    {
      key = "<leader>ud";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.diagnostics():toggle() end";
      lua = true;
      desc = "Toggle Diagnostics";
    }
    {
      key = "<leader>ul";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.line_number():toggle() end";
      lua = true;
      desc = "Toggle Line Numbers";
    }
    {
      key = "<leader>uT";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.treesitter():toggle() end";
      lua = true;
      desc = "Toggle Treesitter";
    }
    {
      key = "<leader>uD";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.dim():toggle() end";
      lua = true;
      desc = "Toggle Dim";
    }
    {
      key = "<leader>ua";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.animate():toggle() end";
      lua = true;
      desc = "Toggle Animation";
    }
    {
      key = "<leader>ug";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.indent():toggle() end";
      lua = true;
      desc = "Toggle Indent Guides";
    }
    {
      key = "<leader>uS";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.scroll():toggle() end";
      lua = true;
      desc = "Toggle Smooth Scroll";
    }
    {
      key = "<leader>uh";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.inlay_hints():toggle() end";
      lua = true;
      desc = "Toggle Inlay Hints";
    }
    {
      key = "<C-W>z";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.zoom():toggle() end";
      lua = true;
      desc = "Toggle Zoom";
    }
    {
      key = "<leader>uZ";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.zoom():toggle() end";
      lua = true;
      desc = "Toggle Zoom";
    }
    {
      key = "<leader>uz";
      mode = [ "n" ];
      action = "function() require('snacks').toggle.zen():toggle() end";
      lua = true;
      desc = "Toggle Zen Mode";
    }
  ];
}
