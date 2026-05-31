{ ... }:
{
  plugins.snacks.settings.picker = {
    enabled = true;
    layout = "my_vertical";
    layouts.my_vertical.layout.__raw = ''
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
    layouts.reverse_dropdown.layout.__raw = ''
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
    # Перекрываем дефолтные snacks-биндинги в input-окне picker'а
    # на наши z4h-стиль функции (см. nvf/plugins/qol/word-kill.nix).
    # Picker input — обычный insert-buffer, поэтому используем
    # buffer-варианты (а не cmd_*).
    win.input.keys = {
      "<C-w>".__raw = ''
        { function() _G.zsh_word_kill.backward_kill_word() end, mode = { "i" }, desc = "z4h backward-kill-word" }
      '';
      "<C-Del>".__raw = ''
        { function() _G.zsh_word_kill.kill_word() end, mode = { "i" }, desc = "z4h kill-word forward" }
      '';
      "<M-BS>".__raw = ''
        { function() _G.zsh_word_kill.backward_kill_zword() end, mode = { "i" }, desc = "z4h backward-kill-zword" }
      '';
    };
  };

  keymaps = [
    {
      key = "<leader>:";
      mode = "n";
      action.__raw = "function() require('snacks').picker.command_history() end";
      options.desc = "Command History";
    }
    {
      key = "<leader>N";
      mode = "n";
      action.__raw = "function() require('snacks').picker.notifications() end";
      options.desc = "Notification History";
    }
    {
      key = "<leader>fb";
      mode = "n";
      action.__raw = "function() require('snacks').picker.buffers() end";
      options.desc = "Buffers";
    }
    {
      key = "<leader>fB";
      mode = "n";
      action.__raw = "function() require('snacks').picker.buffers({ hidden = true, nofile = true }) end";
      options.desc = "Buffers (all)";
    }
    {
      key = "<leader>ff";
      mode = "n";
      action.__raw = "function() require('snacks').picker.files() end";
      options.desc = "Find Files (Root Dir)";
    }
    {
      key = "<leader>fF";
      mode = "n";
      action.__raw = "function() require('snacks').picker.files({ root = false }) end";
      options.desc = "Find Files (cwd)";
    }
    {
      key = "<leader>fg";
      mode = "n";
      action.__raw = "function() require('snacks').picker.git_files() end";
      options.desc = "Find Files (git-files)";
    }
    {
      key = "<leader>fr";
      mode = "n";
      action.__raw = "function() require('snacks').picker.recent() end";
      options.desc = "Recent";
    }
    {
      key = "<leader>fR";
      mode = "n";
      action.__raw = "function() require('snacks').picker.recent({ filter = { cwd = true }}) end";
      options.desc = "Recent (cwd)";
    }
    {
      key = "<leader>fp";
      mode = "n";
      action.__raw = "function() require('snacks').picker.projects() end";
      options.desc = "Projects";
    }
    {
      key = "<leader>sB";
      mode = "n";
      action.__raw = "function() require('snacks').picker.lines() end";
      options.desc = "Buffer Lines";
    }
    {
      key = "<leader>sg";
      mode = "n";
      action.__raw = "function() require('snacks').picker.grep() end";
      options.desc = "Grep (Root Dir)";
    }
    {
      key = "<leader>sG";
      mode = "n";
      action.__raw = "function() require('snacks').picker.grep({ root = false }) end";
      options.desc = "Grep (cwd)";
    }
    {
      key = "<leader>sw";
      mode = [
        "n"
        "x"
      ];
      action.__raw = "function() require('snacks').picker.grep_word() end";
      options.desc = "Visual selection or word (Root Dir)";
    }
    {
      key = "<leader>sd";
      mode = "n";
      action.__raw = "function() require('snacks').picker.diagnostics() end";
      options.desc = "Diagnostics";
    }
    {
      key = "<leader>sD";
      mode = "n";
      action.__raw = "function() require('snacks').picker.diagnostics_buffer() end";
      options.desc = "Buffer Diagnostics";
    }
    {
      key = "<leader>sh";
      mode = "n";
      action.__raw = "function() require('snacks').picker.help() end";
      options.desc = "Help Pages";
    }
    {
      key = "<leader>sk";
      mode = "n";
      action.__raw = "function() require('snacks').picker.keymaps() end";
      options.desc = "Keymaps";
    }
    {
      key = "<leader>su";
      mode = "n";
      action.__raw = "function() require('snacks').picker.undo() end";
      options.desc = "Undotree";
    }
    {
      key = "<leader>sb";
      mode = "n";
      action.__raw = "function() require('snacks').picker.grep_buffers() end";
      options.desc = "Grep Open Buffers";
    }
    {
      key = "<leader>sp";
      mode = "n";
      action.__raw = "function() require('snacks').picker.lazy() end";
      options.desc = "Search for Plugin Spec";
    }
    {
      key = "<leader>sW";
      mode = [
        "n"
        "x"
      ];
      action.__raw = "function() require('snacks').picker.grep_word({ root = false }) end";
      options.desc = "Visual selection or word (cwd)";
    }
    {
      key = ''<leader>s"'';
      mode = "n";
      action.__raw = "function() require('snacks').picker.registers() end";
      options.desc = "Registers";
    }
    {
      key = "<leader>s/";
      mode = "n";
      action.__raw = "function() require('snacks').picker.search_history() end";
      options.desc = "Search History";
    }
    {
      key = "<leader>sa";
      mode = "n";
      action.__raw = "function() require('snacks').picker.autocmds() end";
      options.desc = "Autocmds";
    }
    {
      key = "<leader>sc";
      mode = "n";
      action.__raw = "function() require('snacks').picker.command_history() end";
      options.desc = "Command History";
    }
    {
      key = "<leader>sC";
      mode = "n";
      action.__raw = "function() require('snacks').picker.commands() end";
      options.desc = "Commands";
    }
    {
      key = "<leader>sH";
      mode = "n";
      action.__raw = "function() require('snacks').picker.highlights() end";
      options.desc = "Highlights";
    }
    {
      key = "<leader>si";
      mode = "n";
      action.__raw = "function() require('snacks').picker.icons() end";
      options.desc = "Icons";
    }
    {
      key = "<leader>sj";
      mode = "n";
      action.__raw = "function() require('snacks').picker.jumps() end";
      options.desc = "Jumps";
    }
    {
      key = "<leader>sl";
      mode = "n";
      action.__raw = "function() require('snacks').picker.loclist() end";
      options.desc = "Location List";
    }
    {
      key = "<leader>sM";
      mode = "n";
      action.__raw = "function() require('snacks').picker.man() end";
      options.desc = "Man Pages";
    }
    {
      key = "<leader>sm";
      mode = "n";
      action.__raw = "function() require('snacks').picker.marks() end";
      options.desc = "Marks";
    }
    {
      key = "<leader>sR";
      mode = "n";
      action.__raw = "function() require('snacks').picker.resume() end";
      options.desc = "Resume";
    }
    {
      key = "<leader>sq";
      mode = "n";
      action.__raw = "function() require('snacks').picker.qflist() end";
      options.desc = "Quickfix List";
    }
    {
      key = "<leader>.";
      mode = "n";
      action.__raw = "function() Snacks.scratch() end";
      options.desc = "Toggle Scratch Buffer";
    }
    {
      key = "<leader>S";
      mode = "n";
      action.__raw = "function() Snacks.scratch.select() end";
      options.desc = "Select Scratch Buffer";
    }
  ];
}
