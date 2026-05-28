{ pkgs, ... }:
{
  extraPlugins = [
    {
      plugin = pkgs.vimPlugins.persistent-breakpoints-nvim;
      optional = true;
    }
  ];

  plugins.lz-n = {
    plugins = [
      {
        __unkeyed-1 = "persistent-breakpoints.nvim";
        event = "BufReadPost";
        # persistent-breakpoints вешает sign-handler на nvim-dap → dap должен быть
        # на rtp ДО нашего setup. nvim-dap сам ленив (DeferredUIEnter), здесь
        # вытаскиваем его пораньше.
        before = # lua
          ''
            function()
              require("lz.n").trigger_load("nvim-dap")
            end
          '';
        after = # lua
          ''
            function()
              require("persistent-breakpoints").setup({
                save_dir = vim.fn.stdpath("data") .. "/nvim_checkpoints",
                load_breakpoints_event = { "BufReadPost" },
                always_reload = true,
              })
              -- BufReadPost, который нас триггернул, уже отработал — autocmd из
              -- setup поймает только следующие. Подгружаем bps текущего буфера.
              require("persistent-breakpoints.api").load_breakpoints()
            end
          '';
      }
    ];

    # Fallback-триггеры на случай, если юзер нажал бинд до BufReadPost
    # (`:enew` + `<F9>`). lz.n.keymap(...).set лениво подгружает плагин и
    # сразу запускает action.
    keymaps = [
      {
        plugin = "persistent-breakpoints.nvim";
        key = "<F9>";
        mode = "n";
        action.__raw = "function() require('persistent-breakpoints.api').toggle_breakpoint() end";
        options.desc = "Debug: Toggle Breakpoint (F9)";
      }
      {
        plugin = "persistent-breakpoints.nvim";
        key = "<F21>"; # Shift+F9
        mode = "n";
        action.__raw = "function() require('persistent-breakpoints.api').set_conditional_breakpoint() end";
        options.desc = "Debug: Conditional Breakpoint";
      }
      {
        plugin = "persistent-breakpoints.nvim";
        key = "<leader>dc";
        mode = "n";
        action.__raw = "function() require('persistent-breakpoints.api').clear_all_breakpoints() end";
        options.desc = "Debug: Clear All Breakpoints";
      }
    ];
  };
}
