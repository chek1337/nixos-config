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

    luaConfigRC.autoread-checktime = ''
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI" }, {
        group = vim.api.nvim_create_augroup("AutoReadOnChange", { clear = true }),
        callback = function()
          vim.cmd("silent! checktime")
        end,
      })
    '';
  };
}
