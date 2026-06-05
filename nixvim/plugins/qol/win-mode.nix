{ ... }:
{
  # Two persistent "hydra" modes for window management, entered via <C-w>m / <C-w>r.
  # Implemented with which-key loop=true: press the trigger once, then keep
  # pressing h/j/k/l; the popup stays open. Esc or q to leave.
  #
  # Mirrors the tmux "move mode" and "resize mode" from the tmux config:
  #   <C-w>m  — move mode   : swap window positions with a neighbor
  #   <C-w>r  — resize mode : grow/shrink the current window
  #
  # Both triggers also work as plain key sequences without entering the hydra
  # (e.g. <C-w>mh instantly swaps left, no popup).
  extraConfigLua = ''
    do
      -- Swap the buffer shown in the current window with the buffer shown in
      -- the adjacent window in direction `dir`. The cursor follows the content,
      -- mirroring tmux swap-pane: you stay "with" your buffer after the swap.
      local function swap_win(dir)
        local cur = vim.api.nvim_get_current_win()
        local cur_buf = vim.api.nvim_win_get_buf(cur)
        vim.cmd("wincmd " .. dir)
        local neighbor = vim.api.nvim_get_current_win()
        if neighbor == cur then return end  -- no window in that direction
        local neighbor_buf = vim.api.nvim_win_get_buf(neighbor)
        vim.api.nvim_win_set_buf(cur, neighbor_buf)
        vim.api.nvim_win_set_buf(neighbor, cur_buf)
        -- cursor is now in `neighbor` which holds our original buffer
      end

      -- Move mode: swap current window with a directional neighbor
      vim.keymap.set("n", "<C-w>mh", function() swap_win("h") end, { desc = "Swap ←" })
      vim.keymap.set("n", "<C-w>mj", function() swap_win("j") end, { desc = "Swap ↓" })
      vim.keymap.set("n", "<C-w>mk", function() swap_win("k") end, { desc = "Swap ↑" })
      vim.keymap.set("n", "<C-w>ml", function() swap_win("l") end, { desc = "Swap →" })
      -- Trigger: open the hydra popup and stay in it until Esc
      vim.keymap.set("n", "<C-w>m", function()
        require("which-key").show({ keys = "<C-w>m", loop = true })
      end, { desc = "Move Mode" })

      -- Resize mode: h/l → narrow/widen, j/k → grow/shrink height
      -- lowercase = ×5 cells (coarse), UPPERCASE = ×1 cell (fine-grained)
      vim.keymap.set("n", "<C-w>rh", "<cmd>vertical resize -5<cr>", { desc = "Shrink width" })
      vim.keymap.set("n", "<C-w>rj", "<cmd>resize +5<cr>",           { desc = "Grow height" })
      vim.keymap.set("n", "<C-w>rk", "<cmd>resize -5<cr>",           { desc = "Shrink height" })
      vim.keymap.set("n", "<C-w>rl", "<cmd>vertical resize +5<cr>",  { desc = "Grow width" })
      vim.keymap.set("n", "<C-w>rH", "<cmd>vertical resize -1<cr>",  { desc = "Shrink width ×1" })
      vim.keymap.set("n", "<C-w>rJ", "<cmd>resize +1<cr>",           { desc = "Grow height ×1" })
      vim.keymap.set("n", "<C-w>rK", "<cmd>resize -1<cr>",           { desc = "Shrink height ×1" })
      vim.keymap.set("n", "<C-w>rL", "<cmd>vertical resize +1<cr>",  { desc = "Grow width ×1" })
      -- Trigger: open the hydra popup and stay in it until Esc
      vim.keymap.set("n", "<C-w>r", function()
        require("which-key").show({ keys = "<C-w>r", loop = true })
      end, { desc = "Resize Mode" })
    end
  '';
}
