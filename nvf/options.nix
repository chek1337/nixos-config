{ ... }:
{
  vim = {
    viAlias = true;
    vimAlias = true;

    opts = {
      cursorline = false;
      scrolloff = 2;
      autoread = true;
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      number = true;
      relativenumber = true;
      signcolumn = "yes";
      confirm = true;
    };

    clipboard = {
      enable = true;
      registers = "unnamedplus";
      providers = {
        wl-copy.enable = true;
      };
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    luaConfigRC.autoReload = # lua
      ''
        vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
          group = vim.api.nvim_create_augroup("checktime", { clear = true }),
          callback = function()
            if vim.o.buftype ~= "nofile" then
              vim.cmd("checktime")
            end
          end,
        })
      '';

    luaConfigRC.smartSplitsNav = # lua
      ''
        -- Выставляем @pane-is-vim вручную (smart-splits tmux интеграция сломана в этой версии)
        if vim.env.TMUX and #vim.env.TMUX > 0 then
          vim.fn.system("tmux set-option -p @pane-is-vim 1")
          vim.api.nvim_create_autocmd("VimLeave", {
            callback = function()
              vim.fn.system("tmux set-option -p @pane-is-vim 0")
            end,
          })
        end

        -- Навигация между nvim-сплитами с fallback на tmux-панели
        local function navigate(nvim_dir, tmux_dir)
          local win_before = vim.fn.winnr()
          vim.cmd("wincmd " .. nvim_dir)
          if vim.fn.winnr() == win_before and vim.env.TMUX and #vim.env.TMUX > 0 then
            vim.fn.system("tmux select-pane -" .. tmux_dir)
          end
        end
        vim.keymap.set("n", "<C-h>", function() navigate("h", "L") end, { desc = "Move to left split/pane" })
        vim.keymap.set("n", "<C-j>", function() navigate("j", "D") end, { desc = "Move to bottom split/pane" })
        vim.keymap.set("n", "<C-k>", function() navigate("k", "U") end, { desc = "Move to top split/pane" })
        vim.keymap.set("n", "<C-l>", function() navigate("l", "R") end, { desc = "Move to right split/pane" })
      '';

    luaConfigRC.highlightOnYank = # lua
      ''
        vim.api.nvim_create_autocmd("TextYankPost", {
          group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
          callback = function()
            (vim.hl or vim.highlight).on_yank()
          end,
        })
      '';
  };
}
