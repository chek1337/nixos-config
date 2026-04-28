{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
in
{
  vim.utility.snacks-nvim = {
    enable = true;
    setupOpts.picker = {
      enable = true;
      layout = "my_vertical";
      layouts.my_vertical.layout = mkLuaInline ''
        {
          backdrop = false,
          width = 0.7,
          min_width = 80,
          height = 0.8,
          min_height = 30,
          box = "vertical",
          border = true,
          title = "{title} {live} {flags}",
          title_pos = "center",
          { win = "input", height = 1, border = "bottom" },
          { win = "list", height = 0.3, border = "none" },
          { win = "preview", title = "{preview}", height = 0.6, border = "top" },
        }
      '';
      layouts.reverse_dropdown.layout = mkLuaInline ''
        {
          backdrop = false,
          row = 0,
          width = 0.75,
          min_width = 120,
          height = 0.8,
          border = "none",
          box = "vertical",
          {
            box = "vertical",
            border = true,
            title = "{title} {live} {flags}",
            title_pos = "center",
            { win = "input", height = 1, border = "bottom" },
            { win = "list", border = "none" },
          },
          { win = "preview", title = "{preview}", height = 0.7, border = true },
        }
      '';
    };
  };

  vim.keymaps = [
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
      key = "<leader>sB";
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
      key = "<leader>sb";
      mode = [ "n" ];
      action = "function() require('snacks').picker.grep_buffers() end";
      lua = true;
      desc = "Grep Open Buffers";
    }
    {
      key = "<leader>sp";
      mode = [ "n" ];
      action = "function() require('snacks').picker.lazy() end";
      lua = true;
      desc = "Search for Plugin Spec";
    }
    {
      key = "<leader>sW";
      mode = [
        "n"
        "x"
      ];
      action = "function() require('snacks').picker.grep_word({ root = false }) end";
      lua = true;
      desc = "Visual selection or word (cwd)";
    }
    {
      key = ''<leader>s"'';
      mode = [ "n" ];
      action = "function() require('snacks').picker.registers() end";
      lua = true;
      desc = "Registers";
    }
    {
      key = "<leader>s/";
      mode = [ "n" ];
      action = "function() require('snacks').picker.search_history() end";
      lua = true;
      desc = "Search History";
    }
    {
      key = "<leader>sa";
      mode = [ "n" ];
      action = "function() require('snacks').picker.autocmds() end";
      lua = true;
      desc = "Autocmds";
    }
    {
      key = "<leader>sc";
      mode = [ "n" ];
      action = "function() require('snacks').picker.command_history() end";
      lua = true;
      desc = "Command History";
    }
    {
      key = "<leader>sC";
      mode = [ "n" ];
      action = "function() require('snacks').picker.commands() end";
      lua = true;
      desc = "Commands";
    }
    {
      key = "<leader>sH";
      mode = [ "n" ];
      action = "function() require('snacks').picker.highlights() end";
      lua = true;
      desc = "Highlights";
    }
    {
      key = "<leader>si";
      mode = [ "n" ];
      action = "function() require('snacks').picker.icons() end";
      lua = true;
      desc = "Icons";
    }
    {
      key = "<leader>sj";
      mode = [ "n" ];
      action = "function() require('snacks').picker.jumps() end";
      lua = true;
      desc = "Jumps";
    }
    {
      key = "<leader>sl";
      mode = [ "n" ];
      action = "function() require('snacks').picker.loclist() end";
      lua = true;
      desc = "Location List";
    }
    {
      key = "<leader>sM";
      mode = [ "n" ];
      action = "function() require('snacks').picker.man() end";
      lua = true;
      desc = "Man Pages";
    }
    {
      key = "<leader>sm";
      mode = [ "n" ];
      action = "function() require('snacks').picker.marks() end";
      lua = true;
      desc = "Marks";
    }
    {
      key = "<leader>sR";
      mode = [ "n" ];
      action = "function() require('snacks').picker.resume() end";
      lua = true;
      desc = "Resume";
    }
    {
      key = "<leader>sq";
      mode = [ "n" ];
      action = "function() require('snacks').picker.qflist() end";
      lua = true;
      desc = "Quickfix List";
    }
    {
      key = "<leader>.";
      mode = [ "n" ];
      action = "function() Snacks.scratch() end";
      lua = true;
      desc = "Toggle Scratch Buffer";
    }
  ];
}
