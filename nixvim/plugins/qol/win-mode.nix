{ ... }:
{
  plugins.smart-splits.enable = true;

  # Two persistent "hydra" modes for window management, entered via <C-w>m / <C-w>r.
  # Operations are delegated to smart-splits.nvim so the semantics are
  # left/right/up/down — the plugin picks which border to move based on
  # window position. Pressing `k` in the bottom window grows it; pressing
  # `k` in the top window shrinks it. Same key, intuitive meaning either way.
  #
  # Inside either mode, keep pressing hjkl. Esc or q exits.
  extraConfigLua = ''
    do
      local ss = require("smart-splits")

      local function loop(label, dispatch)
        while true do
          vim.api.nvim_echo({ { label, "ModeMsg" } }, false, {})
          vim.cmd("redraw")
          local ok, ch = pcall(vim.fn.getcharstr)
          if not ok or ch == "\27" or ch == "q" then break end
          dispatch(ch)
        end
        vim.api.nvim_echo({ { "" } }, false, {})
      end

      vim.keymap.set("n", "<C-w>m", function()
        loop("-- MOVE WINDOW (hjkl · q/Esc) --", function(ch)
          if     ch == "h" then ss.swap_buf_left()
          elseif ch == "j" then ss.swap_buf_down()
          elseif ch == "k" then ss.swap_buf_up()
          elseif ch == "l" then ss.swap_buf_right()
          end
        end)
      end, { desc = "Move Mode" })

      -- lowercase = ×5 cells (coarse), UPPERCASE = ×1 cell (fine-grained)
      vim.keymap.set("n", "<C-w>r", function()
        loop("-- RESIZE WINDOW (hjkl=5 · HJKL=1 · q/Esc) --", function(ch)
          if     ch == "h" then ss.resize_left(5)
          elseif ch == "j" then ss.resize_down(5)
          elseif ch == "k" then ss.resize_up(5)
          elseif ch == "l" then ss.resize_right(5)
          elseif ch == "H" then ss.resize_left(1)
          elseif ch == "J" then ss.resize_down(1)
          elseif ch == "K" then ss.resize_up(1)
          elseif ch == "L" then ss.resize_right(1)
          end
        end)
      end, { desc = "Resize Mode" })
    end
  '';
}
