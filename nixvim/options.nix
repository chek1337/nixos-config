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

    -- Go to last cursor position when reopening a buffer; skip gitcommit
    -- so the commit message always opens at line 1
    vim.api.nvim_create_autocmd("BufReadPost", {
      group = vim.api.nvim_create_augroup("last_loc", { clear = true }),
      callback = function(event)
        local buf = event.buf
        if vim.tbl_contains({ "gitcommit" }, vim.bo[buf].filetype) or vim.b[buf].last_loc then
          return
        end
        vim.b[buf].last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
          pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
      end,
    })

    -- Auto-create intermediate directories on :w so you never need mkdir -p first
    -- (skips remote/protocol paths like oil://, scp://)
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
      callback = function(event)
        if event.match:match("^%w%w+:[\\/][\\/]") then return end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
      end,
    })

    -- Re-equalize all splits after the terminal window is resized,
    -- then restore the tab the user was on
    vim.api.nvim_create_autocmd("VimResized", {
      group = vim.api.nvim_create_augroup("resize_splits", { clear = true }),
      callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
      end,
    })

    -- Enable wrap + spell for prose-heavy file types
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("wrap_spell", { clear = true }),
      pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
      end,
    })

    -- conceallevel=0 for JSON so quotes are never hidden by syntax concealment
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("json_conceal", { clear = true }),
      pattern = { "json", "jsonc", "json5" },
      callback = function()
        vim.opt_local.conceallevel = 0
      end,
    })

    -- Keep man pages out of the buffer list so they don't clutter bufferline
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("man_unlisted", { clear = true }),
      pattern = { "man" },
      callback = function(event)
        vim.bo[event.buf].buflisted = false
      end,
    })
  '';
}
