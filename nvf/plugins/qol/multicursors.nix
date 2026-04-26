{ pkgs, ... }:
{
  vim = {
    extraPlugins = with pkgs.vimPlugins; {
      multicursor-nvim = {
        package = multicursor-nvim;
        setup = # lua
          ''
            local mc = require("multicursor-nvim")
            mc.setup()

            vim.keymap.set("n", "<C-LeftMouse>", mc.handleMouse)
            vim.keymap.set("n", "<C-LeftDrag>", mc.handleMouseDrag)
            vim.keymap.set("n", "<C-LeftRelease>", mc.handleMouseRelease)

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
          '';
      };
    };

    keymaps = [
      {
        key = "<leader><up>";
        mode = [
          "n"
          "x"
        ];
        lua = true;
        action = "function() require('multicursor-nvim').lineSkipCursor(-1) end";
        desc = "Skip cursor above";
      }
      {
        key = "<leader><down>";
        mode = [
          "n"
          "x"
        ];
        lua = true;
        action = "function() require('multicursor-nvim').lineSkipCursor(1) end";
        desc = "Skip cursor below";
      }
      {
        key = "<leader>mn";
        mode = [
          "n"
          "x"
        ];
        lua = true;
        action = "function() require('multicursor-nvim').matchAddCursor(1) end";
        desc = "Match-add cursor (next)";
      }
      {
        key = "<leader>mN";
        mode = [
          "n"
          "x"
        ];
        lua = true;
        action = "function() require('multicursor-nvim').matchAddCursor(-1) end";
        desc = "Match-add cursor (prev)";
      }
      {
        key = "<leader>mq";
        mode = [
          "n"
          "x"
        ];
        lua = true;
        action = "function() require('multicursor-nvim').matchSkipCursor(1) end";
        desc = "Match-skip cursor (next)";
      }
      {
        key = "<leader>mQ";
        mode = [
          "n"
          "x"
        ];
        lua = true;
        action = "function() require('multicursor-nvim').matchSkipCursor(-1) end";
        desc = "Match-skip cursor (prev)";
      }
      {
        key = "<leader>ma";
        mode = [
          "n"
          "x"
        ];
        lua = true;
        action = "function() require('multicursor-nvim').matchAllAddCursors() end";
        desc = "Match-add cursors (all)";
      }
      {
        key = "<leader>mm";
        mode = "x";
        lua = true;
        action = "function() require('multicursor-nvim').matchCursors() end";
        desc = "Match cursors in selection (prompt)";
      }
      {
        key = "<leader>mw";
        mode = "x";
        lua = true;
        action = ''
          function()
            local word = vim.fn.expand("<cword>")
            if word == "" then
              vim.notify("No word under cursor", vim.log.levels.WARN)
              return
            end
            require('multicursor-nvim').matchCursors([[\<]] .. vim.fn.escape(word, [[\^$.*~[]]) .. [[\>]])
          end
        '';
        desc = "Match cursors in selection (cword)";
      }
      {
        key = "<leader>ms";
        mode = "x";
        lua = true;
        action = "function() require('multicursor-nvim').splitCursors() end";
        desc = "Split selection on pattern";
      }
      {
        key = "<C-q>";
        mode = [
          "n"
          "x"
        ];
        lua = true;
        action = "function() require('multicursor-nvim').toggleCursor() end";
        desc = "Toggle cursor";
      }
    ];
  };
}
