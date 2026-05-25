{ ... }:
{
  plugins.snacks.settings = {
    scratch.win.height.__raw = "vim.o.lines - 4";
    toggle.enabled = true;
    zen.enabled = true;
    dim.enabled = true;
    rename.enabled = true;
  };

  keymaps = [
    {
      key = "<leader>us";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.option('spell', { name = 'Spelling' }):toggle() end";
      options.desc = "Toggle Spelling";
    }
    {
      key = "<leader>uw";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.option('wrap', { name = 'Wrap' }):toggle() end";
      options.desc = "Toggle Wrap";
    }
    {
      key = "<leader>uL";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.option('relativenumber', { name = 'Relative Number' }):toggle() end";
      options.desc = "Toggle Relative Number";
    }
    {
      key = "<leader>uc";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = 'Conceal Level' }):toggle() end";
      options.desc = "Toggle Conceal Level";
    }
    {
      key = "<leader>uA";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.option('showtabline', { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = 'Tabline' }):toggle() end";
      options.desc = "Toggle Tabline";
    }
    {
      key = "<leader>ub";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):toggle() end";
      options.desc = "Toggle Background";
    }
    {
      key = "<leader>ud";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.diagnostics():toggle() end";
      options.desc = "Toggle Diagnostics";
    }
    {
      key = "<leader>ul";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.line_number():toggle() end";
      options.desc = "Toggle Line Numbers";
    }
    {
      key = "<leader>uT";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.treesitter():toggle() end";
      options.desc = "Toggle Treesitter";
    }
    {
      key = "<leader>uD";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.dim():toggle() end";
      options.desc = "Toggle Dim";
    }
    {
      key = "<leader>ua";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.animate():toggle() end";
      options.desc = "Toggle Animation";
    }
    {
      key = "<leader>ug";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.indent():toggle() end";
      options.desc = "Toggle Indent Guides";
    }
    {
      key = "<leader>uS";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.scroll():toggle() end";
      options.desc = "Toggle Smooth Scroll";
    }
    {
      key = "<leader>uh";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.inlay_hints():toggle() end";
      options.desc = "Toggle Inlay Hints";
    }
    {
      key = "<C-W>z";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.zoom():toggle() end";
      options.desc = "Toggle Zoom";
    }
    {
      key = "<leader>uZ";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.zoom():toggle() end";
      options.desc = "Toggle Zoom";
    }
    {
      key = "<leader>uz";
      mode = "n";
      action.__raw = "function() require('snacks').toggle.zen():toggle() end";
      options.desc = "Toggle Zen Mode";
    }
  ];
}
