{ ... }:
let
  # Russian (jcukenwin) labels, positionally equivalent to the Latin
  # default "asdfghjklqwertyuiopzxcvbnm". Used by the Cyrillic-duplicate
  # triggers below so jump labels match what the Russian layout produces.
  ruLabels = "фывапролдйцукенгшщзячсмить";
in
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

    # Russian-layout duplicates: the physical key (f/s/S/t/T/F) sends the
    # Cyrillic char below when the OS layout is Russian. These trigger flash
    # with Russian labels, so you never switch layout to use the hints.
    {
      key = "а";
      mode = [
        "n"
        "x"
        "o"
      ];
      action.__raw = "function() require('flash').jump({ labels = '${ruLabels}' }) end";
      options.desc = "Flash Jump (RU)";
    }
    {
      key = "ы";
      mode = [
        "n"
        "x"
        "o"
      ];
      action.__raw = "function() require('flash').jump({ labels = '${ruLabels}', mode = 'char', highlight = { backdrop = true }, jump = { register = false }, search = { forward = true, wrap = false } }) end";
      options.desc = "Flash Char Forward (RU)";
    }
    {
      key = "Ы";
      mode = [
        "n"
        "x"
        "o"
      ];
      action.__raw = "function() require('flash').jump({ labels = '${ruLabels}', mode = 'char', highlight = { backdrop = true }, jump = { register = false }, search = { forward = false, wrap = false } }) end";
      options.desc = "Flash Char Backward (RU)";
    }
    {
      key = "е";
      mode = [
        "n"
        "x"
        "o"
      ];
      action.__raw = "function() require('flash').jump({ labels = '${ruLabels}', mode = 'char', highlight = { backdrop = true }, jump = { register = false, offset = -1 }, search = { forward = true, wrap = false } }) end";
      options.desc = "Flash Char Forward before (RU)";
    }
    {
      key = "Е";
      mode = [
        "n"
        "x"
        "o"
      ];
      action.__raw = "function() require('flash').jump({ labels = '${ruLabels}', mode = 'char', highlight = { backdrop = true }, jump = { register = false, offset = 1 }, search = { forward = false, wrap = false } }) end";
      options.desc = "Flash Char Backward before (RU)";
    }
    {
      key = "А";
      mode = [
        "n"
        "x"
        "o"
      ];
      action.__raw = "function() require('flash').treesitter({ labels = '${ruLabels}' }) end";
      options.desc = "Flash Treesitter (RU)";
    }
  ];
}
