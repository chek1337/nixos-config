{ lib, ... }:
{
  vim.utility.snacks-nvim = {
    enable = true;
    setupOpts = {
      bigfile.enable = true;
      bufdelete.enable = true;
      gitbrowse.enable = true;
      picker.enable = true;
      toggle.enable = true;
      zen.enable = true;
      dim.enable = true;
      animate.enable = true;
      indent.enable = true;
      scroll = {
        enable = true;
        animate = {
          duration = {
            step = 10;
            total = 200;
          };
          easing = "outExpo";
        };
      };
      notifier = {
        enable = true;
        timeout = 2000;
        style = "minimal";
      };
      statuscolumn.enable = true;
      words.enable = true;
      scope.enable = true;
      quickfile.enable = true;
    };
  };

  vim.keymaps = [
    {
      key = "<leader>bd";
      mode = [ "n" ];
      action = "function() require('snacks').bufdelete() end";
      lua = true;
      desc = "Delete Buffer";
    }
    {
      key = "<leader>bo";
      mode = [ "n" ];
      action = "function() require('snacks').bufdelete.other() end";
      lua = true;
      desc = "Delete Other Buffers";
    }
    {
      key = "<leader>gB";
      mode = [
        "n"
        "x"
      ];
      action = "function() require('snacks').gitbrowse() end";
      lua = true;
      desc = "Git Browse (open)";
    }
    {
      key = "<leader>gY";
      mode = [
        "n"
        "x"
      ];
      action = "function() require('snacks').gitbrowse({ open = function(url) vim.fn.setreg('+', url) end, notify = false }) end";
      lua = true;
      desc = "Git Browse (copy)";
    }
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
      key = "<leader>wm";
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
    {
      key = "<leader>:";
      mode = [ "n" ];
      action = "function() require('snacks').picker.command_history() end";
      lua = true;
      desc = "Command History";
    }
    {
      key = "<leader>N";
      mode = [ "n" ];
      action = "function() require('snacks').picker.notifications() end";
      lua = true;
      desc = "Notification History";
    }
    {
      key = "<leader>fb";
      mode = [ "n" ];
      action = "function() require('snacks').picker.buffers() end";
      lua = true;
      desc = "Buffers";
    }
    {
      key = "<leader>fB";
      mode = [ "n" ];
      action = "function() require('snacks').picker.buffers({ hidden = true, nofile = true }) end";
      lua = true;
      desc = "Buffers (all)";
    }
    {
      key = "<leader>ff";
      mode = [ "n" ];
      action = "function() require('snacks').picker.files() end";
      lua = true;
      desc = "Find Files (Root Dir)";
    }
    {
      key = "<leader>fF";
      mode = [ "n" ];
      action = "function() require('snacks').picker.files({ root = false }) end";
      lua = true;
      desc = "Find Files (cwd)";
    }
    {
      key = "<leader>fg";
      mode = [ "n" ];
      action = "function() require('snacks').picker.git_files() end";
      lua = true;
      desc = "Find Files (git-files)";
    }
    {
      key = "<leader>fr";
      mode = [ "n" ];
      action = "function() require('snacks').picker.recent() end";
      lua = true;
      desc = "Recent";
    }
    {
      key = "<leader>fR";
      mode = [ "n" ];
      action = "function() require('snacks').picker.recent({ filter = { cwd = true }}) end";
      lua = true;
      desc = "Recent (cwd)";
    }
    {
      key = "<leader>fp";
      mode = [ "n" ];
      action = "function() require('snacks').picker.projects() end";
      lua = true;
      desc = "Projects";
    }
    {
      key = "<leader>gS";
      mode = [ "n" ];
      action = "function() require('snacks').picker.git_stash() end";
      lua = true;
      desc = "Git Stash";
    }
    {
      key = "<leader>sb";
      mode = [ "n" ];
      action = "function() require('snacks').picker.lines() end";
      lua = true;
      desc = "Buffer Lines";
    }
    {
      key = "<leader>sg";
      mode = [ "n" ];
      action = "function() require('snacks').picker.grep() end";
      lua = true;
      desc = "Grep (Root Dir)";
    }
    {
      key = "<leader>sG";
      mode = [ "n" ];
      action = "function() require('snacks').picker.grep({ root = false }) end";
      lua = true;
      desc = "Grep (cwd)";
    }
    {
      key = "<leader>sw";
      mode = [
        "n"
        "x"
      ];
      action = "function() require('snacks').picker.grep_word() end";
      lua = true;
      desc = "Visual selection or word (Root Dir)";
    }
    {
      key = "<leader>sd";
      mode = [ "n" ];
      action = "function() require('snacks').picker.diagnostics() end";
      lua = true;
      desc = "Diagnostics";
    }
    {
      key = "<leader>sD";
      mode = [ "n" ];
      action = "function() require('snacks').picker.diagnostics_buffer() end";
      lua = true;
      desc = "Buffer Diagnostics";
    }
    {
      key = "<leader>sh";
      mode = [ "n" ];
      action = "function() require('snacks').picker.help() end";
      lua = true;
      desc = "Help Pages";
    }
    {
      key = "<leader>sk";
      mode = [ "n" ];
      action = "function() require('snacks').picker.keymaps() end";
      lua = true;
      desc = "Keymaps";
    }
    {
      key = "<leader>su";
      mode = [ "n" ];
      action = "function() require('snacks').picker.undo() end";
      lua = true;
      desc = "Undotree";
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
  ];
}
