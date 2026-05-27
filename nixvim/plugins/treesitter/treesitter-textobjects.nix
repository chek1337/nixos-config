{ pkgs, ... }:
let
  ox = [
    "o"
    "x"
  ];
  nxo = [
    "n"
    "x"
    "o"
  ];

  mkSelect = key: variant: obj: {
    inherit key;
    mode = ox;
    action.__raw = "function() require('nvim-treesitter-textobjects.select').select_textobject('${obj}.${variant}', 'textobjects') end";
    options.desc = "${variant} ${obj}";
  };

  mkMove = key: fn: obj: {
    inherit key;
    mode = nxo;
    action.__raw = "function() require('nvim-treesitter-textobjects.move').${fn}('${obj}', 'textobjects') end";
    options.desc = "${key} ${obj}";
  };

  selectObjs = [
    {
      i = "if";
      a = "af";
      obj = "@function";
    }
    {
      i = "ic";
      a = "ac";
      obj = "@class";
    }
    {
      i = "ia";
      a = "aa";
      obj = "@parameter";
    }
    {
      i = "iC";
      a = "aC";
      obj = "@call";
    }
    {
      i = "ib";
      a = "ab";
      obj = "@block";
    }
    {
      i = "i?";
      a = "a?";
      obj = "@conditional";
    }
    {
      i = "il";
      a = "al";
      obj = "@loop";
    }
    {
      i = "i/";
      a = "a/";
      obj = "@comment";
    }
    {
      i = "ir";
      a = "ar";
      obj = "@return";
    }
    {
      i = "i=";
      a = "a=";
      obj = "@assignment";
    }
  ];
in
{
  extraPlugins = [ pkgs.vimPlugins.nvim-treesitter-textobjects ];

  extraConfigLua = ''
    require("nvim-treesitter-textobjects.config").update({
      select = { lookahead = true },
      move   = { set_jumps = true },
    })
  '';

  keymaps =
    builtins.concatMap (m: [
      (mkSelect m.i "inner" m.obj)
      (mkSelect m.a "outer" m.obj)
    ]) selectObjs
    ++ [
      (mkMove "]f" "goto_next_start" "@function.outer")
      (mkMove "[f" "goto_previous_start" "@function.outer")
      (mkMove "]F" "goto_next_end" "@function.outer")
      (mkMove "[F" "goto_previous_end" "@function.outer")
      (mkMove "]c" "goto_next_start" "@class.outer")
      (mkMove "[c" "goto_previous_start" "@class.outer")
      (mkMove "]l" "goto_next_start" "@loop.outer")
      (mkMove "[l" "goto_previous_start" "@loop.outer")
      (mkMove "]?" "goto_next_start" "@conditional.outer")
      (mkMove "[?" "goto_previous_start" "@conditional.outer")
      {
        key = "<A-l>";
        mode = "n";
        action.__raw = "function() require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner') end";
        options.desc = "swap next parameter";
      }
      {
        key = "<A-h>";
        mode = "n";
        action.__raw = "function() require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner') end";
        options.desc = "swap prev parameter";
      }
    ];
}
