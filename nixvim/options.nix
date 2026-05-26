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
