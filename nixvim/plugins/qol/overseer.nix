{ ... }:
{
  plugins.overseer = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
    settings = {
      task_list = {
        direction = "bottom";
        min_height = 10;
        max_height = 20;
      };
      # Templates auto-detect make, npm, cargo, just, etc. and feed errors
      # into the quickfix list via on_output_quickfix.
      component_aliases = {
        default = [
          "on_exit_set_status"
          "on_complete_notify"
          {
            __unkeyed-1 = "on_complete_dispose";
            require_view = [
              "SUCCESS"
              "FAILURE"
            ];
          }
          "on_output_quickfix"
          {
            __unkeyed-1 = "unique";
            replace = true;
          }
        ];
      };
    };
  };

  keymaps = [
    {
      key = "<leader>or";
      mode = "n";
      action = "<cmd>OverseerRun<cr>";
      options.desc = "Run task";
    }
    {
      key = "<leader>ot";
      mode = "n";
      action = "<cmd>OverseerToggle<cr>";
      options.desc = "Toggle task list";
    }
    {
      key = "<leader>op";
      mode = "n";
      action.__raw = ''
        function()
          local overseer = require("overseer")
          local tasks = overseer.list_tasks({})
          if #tasks == 0 then
            vim.notify("No overseer tasks", vim.log.levels.INFO)
            return
          end
          tasks[1]:open_output("float")
        end
      '';
      options.desc = "Peek latest task output (float)";
    }
    {
      key = "<leader>oa";
      mode = "n";
      action = "<cmd>OverseerTaskAction<cr>";
      options.desc = "Task action menu";
    }
    {
      key = "<leader>oR";
      mode = "n";
      action = "<cmd>OverseerShell<cr>";
      options.desc = "Run shell command";
    }
  ];

  extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "OverseerOutput",
      callback = function(args)
        vim.keymap.set("n", "q", "<cmd>close<cr>", {
          buffer = args.buf,
          desc = "Close overseer output window",
        })
      end,
    })
  '';
}
