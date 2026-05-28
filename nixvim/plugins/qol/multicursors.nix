{ pkgs, ... }:
{
  extraPlugins = [
    {
      plugin = pkgs.vimPlugins.multicursor-nvim;
      optional = true;
    }
  ];

  plugins.lz-n.plugins = [
    {
      __unkeyed-1 = "multicursor.nvim";
      keys = [
        {
          __unkeyed-1 = "<C-q>";
          mode = [
            "n"
            "x"
          ];
          desc = "Toggle cursor";
        }
        "<C-LeftMouse>"
        "<C-LeftDrag>"
        "<C-LeftRelease>"
        {
          __unkeyed-1 = "<leader><up>";
          mode = [
            "n"
            "x"
          ];
          desc = "Skip cursor above";
        }
        {
          __unkeyed-1 = "<leader><down>";
          mode = [
            "n"
            "x"
          ];
          desc = "Skip cursor below";
        }
        {
          __unkeyed-1 = "<leader>mt";
          desc = "Toggle multicursor arrows";
        }
        {
          __unkeyed-1 = "<leader>mn";
          mode = [
            "n"
            "x"
          ];
          desc = "Match-add cursor (next)";
        }
        {
          __unkeyed-1 = "<leader>mN";
          mode = [
            "n"
            "x"
          ];
          desc = "Match-add cursor (prev)";
        }
        {
          __unkeyed-1 = "<leader>mq";
          mode = [
            "n"
            "x"
          ];
          desc = "Match-skip cursor (next)";
        }
        {
          __unkeyed-1 = "<leader>mQ";
          mode = [
            "n"
            "x"
          ];
          desc = "Match-skip cursor (prev)";
        }
        {
          __unkeyed-1 = "<leader>ma";
          mode = [
            "n"
            "x"
          ];
          desc = "Match-add cursors (all)";
        }
        {
          __unkeyed-1 = "<leader>mm";
          mode = "x";
          desc = "Match cursors in selection (prompt)";
        }
        {
          __unkeyed-1 = "<leader>mw";
          mode = "x";
          desc = "Match cursors in selection (cword)";
        }
        {
          __unkeyed-1 = "<leader>ms";
          mode = "x";
          desc = "Split selection on pattern";
        }
      ];
      after = # lua
        ''
          function()
            local mc = require("multicursor-nvim")
            mc.setup()

            vim.keymap.set("n", "<C-LeftMouse>", mc.handleMouse)
            vim.keymap.set("n", "<C-LeftDrag>", mc.handleMouseDrag)
            vim.keymap.set("n", "<C-LeftRelease>", mc.handleMouseRelease)

            local nx = { "n", "x" }
            vim.keymap.set(nx, "<C-q>", function() mc.toggleCursor() end,
              { silent = true, desc = "Toggle cursor" })
            vim.keymap.set(nx, "<leader><up>", function() mc.lineSkipCursor(-1) end,
              { silent = true, desc = "Skip cursor above" })
            vim.keymap.set(nx, "<leader><down>", function() mc.lineSkipCursor(1) end,
              { silent = true, desc = "Skip cursor below" })
            vim.keymap.set(nx, "<leader>mn", function() mc.matchAddCursor(1) end,
              { silent = true, desc = "Match-add cursor (next)" })
            vim.keymap.set(nx, "<leader>mN", function() mc.matchAddCursor(-1) end,
              { silent = true, desc = "Match-add cursor (prev)" })
            vim.keymap.set(nx, "<leader>mq", function() mc.matchSkipCursor(1) end,
              { silent = true, desc = "Match-skip cursor (next)" })
            vim.keymap.set(nx, "<leader>mQ", function() mc.matchSkipCursor(-1) end,
              { silent = true, desc = "Match-skip cursor (prev)" })
            vim.keymap.set(nx, "<leader>ma", function() mc.matchAllAddCursors() end,
              { silent = true, desc = "Match-add cursors (all)" })
            vim.keymap.set("x", "<leader>mm", function() mc.matchCursors() end,
              { silent = true, desc = "Match cursors in selection (prompt)" })
            vim.keymap.set("x", "<leader>ms", function() mc.splitCursors() end,
              { silent = true, desc = "Split selection on pattern" })
            vim.keymap.set("x", "<leader>mw", function()
              local word = vim.fn.expand("<cword>")
              if word == "" then
                vim.notify("No word under cursor", vim.log.levels.WARN)
                return
              end
              mc.matchCursors([[\<]] .. vim.fn.escape(word, [[\^$.*~[]]) .. [[\>]])
            end, { silent = true, desc = "Match cursors in selection (cword)" })

            mc.addKeymapLayer(function(layerSet)
              layerSet({ "n", "x" }, "<left>", mc.prevCursor)
              layerSet({ "n", "x" }, "<right>", mc.nextCursor)
              layerSet({ "n", "x" }, "<bs>", mc.deleteCursor)

              layerSet("n", "<esc>", function()
                if not mc.cursorsEnabled() then
                  mc.enableCursors()
                else
                  mc.clearCursors()
                end
              end)
            end)

            local arrow_toggle = Snacks.toggle({
              name = "Multicursor arrows",
              get = function()
                return vim.g.multicursor_arrows == true
              end,
              set = function(state)
                vim.g.multicursor_arrows = state
                if state then
                  vim.keymap.set({ "n", "x" }, "<up>", function() mc.lineAddCursor(-1) end,
                    { silent = true, desc = "Add cursor above" })
                  vim.keymap.set({ "n", "x" }, "<down>", function() mc.lineAddCursor(1) end,
                    { silent = true, desc = "Add cursor below" })
                else
                  pcall(vim.keymap.del, { "n", "x" }, "<up>")
                  pcall(vim.keymap.del, { "n", "x" }, "<down>")
                end
              end,
            })

            arrow_toggle:map("<leader>mt")
            arrow_toggle:set(false)
          end
        '';
    }
  ];
}
