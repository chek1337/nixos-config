{ ... }:
{
  plugins.flash = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
    settings = {
      search.mode = "search";
      modes.char.enabled = false;
    };
  };

  keymaps = [
    {
      key = "f";
      mode = [
        "n"
        "x"
        "o"
      ];
      action.__raw = "function() require('flash').jump() end";
      options.desc = "Flash Jump";
    }
    {
      key = "s";
      mode = [
        "n"
        "x"
        "o"
      ];
      action.__raw = "function() require('flash').jump({ mode = 'char', highlight = { backdrop = true }, jump = { register = false }, search = { forward = true, wrap = false } }) end";
      options.desc = "Flash Char Forward (on char)";
    }
    {
      key = "S";
      mode = [
        "n"
        "x"
        "o"
      ];
      action.__raw = "function() require('flash').jump({ mode = 'char', highlight = { backdrop = true }, jump = { register = false }, search = { forward = false, wrap = false } }) end";
      options.desc = "Flash Char Backward (on char)";
    }
    {
      key = "t";
      mode = [
        "n"
        "x"
        "o"
      ];
      action.__raw = "function() require('flash').jump({ mode = 'char', highlight = { backdrop = true }, jump = { register = false, offset = -1 }, search = { forward = true, wrap = false } }) end";
      options.desc = "Flash Char Forward (before char)";
    }
    {
      key = "T";
      mode = [
        "n"
        "x"
        "o"
      ];
      action.__raw = "function() require('flash').jump({ mode = 'char', highlight = { backdrop = true }, jump = { register = false, offset = 1 }, search = { forward = false, wrap = false } }) end";
      options.desc = "Flash Char Backward (before char)";
    }
    {
      key = "F";
      mode = [
        "n"
        "x"
        "o"
      ];
      action.__raw = "function() require('flash').treesitter() end";
      options.desc = "Flash Treesitter";
    }
  ];
}
