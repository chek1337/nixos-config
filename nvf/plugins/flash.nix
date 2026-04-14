{ ... }:
{
  vim.utility.motion.flash-nvim = {
    enable = true;
    setupOpts = {
      search.mode = "search";
      modes.char.enabled = false;
    };
  };

  vim.lazy.plugins."flash-nvim".event = "UIEnter";

  vim.keymaps = [
    {
      key = "f";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "function() require('flash').jump() end";
      lua = true;
      desc = "Flash Jump";
    }
    # s/S: land ON the char (f/F behaviour), forward and backward
    {
      key = "s";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "function() require('flash').jump({ mode = 'char', highlight = { backdrop = true }, jump = { register = false }, search = { forward = true, wrap = false } }) end";
      lua = true;
      desc = "Flash Char Forward (on char)";
    }
    {
      key = "S";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "function() require('flash').jump({ mode = 'char', highlight = { backdrop = true }, jump = { register = false }, search = { forward = false, wrap = false } }) end";
      lua = true;
      desc = "Flash Char Backward (on char)";
    }
    # t/T: land BEFORE the char, forward and backward
    {
      key = "t";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "function() require('flash').jump({ mode = 'char', highlight = { backdrop = true }, jump = { register = false, offset = -1 }, search = { forward = true, wrap = false } }) end";
      lua = true;
      desc = "Flash Char Forward (before char)";
    }
    {
      key = "T";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "function() require('flash').jump({ mode = 'char', highlight = { backdrop = true }, jump = { register = false, offset = 1 }, search = { forward = false, wrap = false } }) end";
      lua = true;
      desc = "Flash Char Backward (before char)";
    }
    # F: treesitter selection
    {
      key = "F";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = "function() require('flash').treesitter() end";
      lua = true;
      desc = "Flash Treesitter";
    }
  ];
}
