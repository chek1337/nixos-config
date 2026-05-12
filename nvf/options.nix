{ lib, ... }:
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
      undolevels = 10000;
      spell = lib.mkForce false;
    };

    searchCase = "smart";

    undoFile.enable = true;

    clipboard = {
      enable = true;
      registers = "unnamedplus";
      providers = {
        wl-copy.enable = true;
      };
    };

    vendoredKeymaps.enable = false;

    spellcheck = {
      enable = true;
      languages = [
        "en"
        "ru"
      ];
    };

    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };

    luaConfigRC.autoread-checktime = # lua
      ''
        vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI" }, {
          group = vim.api.nvim_create_augroup("AutoReadOnChange", { clear = true }),
          callback = function()
            vim.cmd("silent! checktime")
          end,
        })
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

    luaConfigRC.close-with-q = # lua
      ''
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

  };
}
