{ lib, ... }:
{
  viAlias = true;
  vimAlias = true;

  globals = {
    mapleader = " ";
    maplocalleader = "\\";
  };

  opts = {
    number = true;
    relativenumber = true;
    signcolumn = "yes";
    cursorline = false;
    scrolloff = 2;
    guicursor = "n-v-c-sm:block-blinkwait0-blinkoff0-blinkon0,i-ci-ve:ver25-blinkwait0-blinkoff0-blinkon0,r-cr-o:hor20-blinkwait0-blinkoff0-blinkon0";

    expandtab = true;
    tabstop = 2;
    shiftwidth = 2;

    ignorecase = true;
    smartcase = true;

    undofile = true;
    undolevels = 10000;

    confirm = true;
    autoread = true;
    exrc = true;

    spell = lib.mkForce false;
    spelllang = "en,ru";

    clipboard = "unnamedplus";
  };

  clipboard.providers.wl-copy.enable = true;

  extraConfigLua = ''
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI" }, {
      group = vim.api.nvim_create_augroup("AutoReadOnChange", { clear = true }),
      callback = function()
        vim.cmd("silent! checktime")
      end,
    })

    -- Close all non-file windows before VimLeave so persistence.nvim не
    -- сохраняет в сессию qf/neogit/dap-view/trouble/snacks/etc. (иначе при
    -- следующей загрузке появляются пустые скретч-окна и порождённые tabs).
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = vim.api.nvim_create_augroup("close_non_file_windows", { clear = true }),
      callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype ~= "" then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
        -- Сначала прыгаем на tab с реальным файловым буфером, потом tabonly,
        -- чтобы не остался пустой holdover-tab от вычищенных скретч-окон.
        local found = false
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
          if found then break end
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
              vim.api.nvim_set_current_tabpage(tab)
              found = true
              break
            end
          end
        end
        vim.cmd("silent! tabonly")
      end,
    })

    vim.api.nvim_create_autocmd("TextYankPost", {
      group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
      callback = function()
        (vim.hl or vim.highlight).on_yank()
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
      pattern = {
        "PlenaryTestPopup",
        "checkhealth",
        "dap-float",
        "dbout",
        "gitsigns-blame",
        "grug-far",
        "help",
        "lspinfo",
        "neotest-output",
        "neotest-output-panel",
        "neotest-summary",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
      },
      callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
          vim.keymap.set("n", "q", function()
            vim.cmd("close")
            pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
          end, {
            buffer = event.buf,
            silent = true,
            desc = "Quit buffer",
          })
        end)
      end,
    })
  '';
}
