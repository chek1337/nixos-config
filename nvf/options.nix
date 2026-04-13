{ ... }:
{
  vim = {
    viAlias = true;
    vimAlias = true;

    theme = {
      enable = true;
      name = "nord";
      style = "dark";
    };

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
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
  };
}
