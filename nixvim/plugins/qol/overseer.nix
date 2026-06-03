{ ... }:
{
  plugins.overseer = {
    enable = true;
    lazyLoad.settings.cmd = [
      "OverseerOpen"
      "OverseerClose"
      "OverseerToggle"
      "OverseerSaveBundle"
      "OverseerLoadBundle"
      "OverseerDeleteBundle"
      "OverseerRunCmd"
      "OverseerRun"
      "OverseerInfo"
      "OverseerBuild"
      "OverseerQuickAction"
      "OverseerTaskAction"
      "OverseerClearCache"
    ];
    settings = {
      task_list = {
        direction = "bottom";
        min_height = 10;
        max_height = 20;
        default_detail = 1;
      };
      # Templates auto-detect make, npm, cargo, just, etc. and feed errors
      # into the quickfix list via on_output_quickfix.
      component_aliases = {
        default = [
          "on_output_summarize"
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
      key = "<leader>oa";
      mode = "n";
      action = "<cmd>OverseerQuickAction<cr>";
      options.desc = "Quick action on last task";
    }
    {
      key = "<leader>oA";
      mode = "n";
      action = "<cmd>OverseerTaskAction<cr>";
      options.desc = "Task action menu";
    }
    {
      key = "<leader>oR";
      mode = "n";
      action = "<cmd>OverseerRunCmd<cr>";
      options.desc = "Run shell command";
    }
    {
      key = "<leader>oi";
      mode = "n";
      action = "<cmd>OverseerInfo<cr>";
      options.desc = "Templates info";
    }
    {
      key = "<leader>ob";
      mode = "n";
      action = "<cmd>OverseerBuild<cr>";
      options.desc = "Build task interactively";
    }
    {
      key = "<leader>oc";
      mode = "n";
      action = "<cmd>OverseerClearCache<cr>";
      options.desc = "Clear template cache";
    }
    {
      key = "<leader>os";
      mode = "n";
      action = "<cmd>OverseerSaveBundle<cr>";
      options.desc = "Save bundle";
    }
    {
      key = "<leader>ol";
      mode = "n";
      action = "<cmd>OverseerLoadBundle<cr>";
      options.desc = "Load bundle";
    }
  ];
}
