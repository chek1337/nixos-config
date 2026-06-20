{ ... }:
{
  keymaps = [
    # Better up/down: moves by visual lines when no count given — useful when
    # wrap is on; 5j still jumps 5 real lines because of the count check
    {
      key = "j";
      mode = [
        "n"
        "x"
      ];
      action = "v:count == 0 ? 'gj' : 'j'";
      options.expr = true;
      options.silent = true;
      options.desc = "Down";
    }
    {
      key = "k";
      mode = [
        "n"
        "x"
      ];
      action = "v:count == 0 ? 'gk' : 'k'";
      options.expr = true;
      options.silent = true;
      options.desc = "Up";
    }

    {
      key = "jk";
      mode = "i";
      action = "<Esc>";
      options.desc = "Exit insert mode with jk";
    }
    {
      key = "jj";
      mode = "i";
      action = "<Esc>";
      options.desc = "Exit insert mode with jj";
    }

    {
      key = "q";
      mode = [
        "n"
        "v"
      ];
      action = "<Nop>";
      options.desc = "Disable macros";
    }
    {
      key = "<M-q>";
      mode = [
        "n"
        "v"
      ];
      action = "q";
      options.desc = "Write macros";
    }

    {
      key = "m";
      mode = [
        "n"
        "v"
      ];
      action = "<Nop>";
      options.desc = "Disable marks";
    }
    {
      key = "<M-m>";
      mode = [
        "n"
        "v"
      ];
      action = "m";
      options.desc = "Set mark";
    }

    {
      key = "u";
      mode = "v";
      action = "<Nop>";
      options.desc = "Disable lowercase selection";
    }
    {
      key = "U";
      mode = "v";
      action = "<Nop>";
      options.desc = "Disable uppercase selection";
    }
    {
      key = "<M-u>";
      mode = "v";
      action = "u";
      options.desc = "Lowercase selection";
    }
    {
      key = "<M-U>";
      mode = "v";
      action = "U";
      options.desc = "Uppercase selection";
    }

    {
      key = "<Esc>";
      mode = "n";
      action = "<cmd>nohlsearch<cr><esc>";
      options.desc = "Clear search highlight";
    }
    {
      key = "<Esc>";
      mode = "t";
      action = "<C-\\><C-n>";
      options.desc = "Exit terminal mode";
    }

    {
      key = "p";
      mode = "x";
      action = ''"_dP'';
      options.desc = "Paste without overwriting clipboard";
    }

    {
      key = "x";
      mode = [
        "n"
        "v"
      ];
      action = ''"_x'';
      options.desc = "Delete char without overwriting clipboard";
    }
    {
      key = "X";
      mode = [
        "n"
        "v"
      ];
      action = ''"_X'';
      options.desc = "Delete char before without overwriting clipboard";
    }

    {
      key = "c";
      mode = [
        "n"
        "v"
      ];
      action = ''"_c'';
      options.desc = "Change without overwriting clipboard";
    }
    {
      key = "C";
      mode = "n";
      action = ''"_C'';
      options.desc = "Change to EOL without overwriting clipboard";
    }
    # {
    #   key = "s";
    #   mode = [
    #     "n"
    #     "v"
    #   ];
    #   action = ''"_s'';
    #   options.desc = "Substitute without overwriting clipboard";
    # }
    # {
    #   key = "S";
    #   mode = "n";
    #   action = ''"_S'';
    #   options.desc = "Substitute line without overwriting clipboard";
    # }

    {
      key = "yp";
      mode = "n";
      action.__raw = # lua
        ''
          function()
            local path = vim.fn.expand("%:p")
            if path == "" then
              vim.notify("No file path to copy", vim.log.levels.WARN)
              return
            end
            vim.fn.setreg("+", path)
            vim.notify("Copied: " .. path)
          end
        '';
      options.desc = "Yank absolute file path";
    }

    # {
    #   key = "<C-h>";
    #   mode = "i";
    #   action = "<Left>";
    # }
    # {
    #   key = "<C-j>";
    #   mode = "i";
    #   action = "<Down>";
    # }
    # {
    #   key = "<C-k>";
    #   mode = "i";
    #   action = "<Up>";
    # }
    # {
    #   key = "<C-l>";
    #   mode = "i";
    #   action = "<Right>";
    # }

    {
      key = "J";
      mode = "n";
      action = "<cmd>BufferLineCyclePrev<cr>";
      options.desc = "Previous buffer";
    }
    {
      key = "K";
      mode = "n";
      action = "<cmd>BufferLineCycleNext<cr>";
      options.desc = "Next buffer";
    }

    {
      key = "H";
      mode = "n";
      action = "<Nop>";
      options.silent = true;
    }
    {
      key = "L";
      mode = "n";
      action = "<Nop>";
      options.silent = true;
    }

    # Switch to the alternate (last) buffer — faster than :b#
    {
      key = "<leader>bb";
      mode = "n";
      action = "<cmd>e #<cr>";
      options.desc = "Switch to Other Buffer";
    }
    {
      key = "<leader>`";
      mode = "n";
      action = "<cmd>e #<cr>";
      options.desc = "Switch to Other Buffer";
    }
    {
      key = "<leader>bx";
      mode = "n";
      action.__raw = "function() require('snacks').bufdelete() end";
      options.desc = "Delete Buffer";
    }
    {
      key = "<leader>bo";
      mode = "n";
      action.__raw = ''
        function()
          require('snacks').bufdelete({
            filter = function(b)
              return b ~= vim.api.nvim_get_current_buf()
                and vim.bo[b].filetype ~= "qf"
            end,
          })
        end
      '';
      options.desc = "Delete Other Buffers";
    }
    # Open a new empty buffer
    {
      key = "<leader>fn";
      mode = "n";
      action = "<cmd>enew<cr>";
      options.desc = "New File";
    }

    # Quickfix list
    {
      key = "<leader>xq";
      mode = "n";
      action.__raw = # lua
        ''
          function()
            local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
            if not success and err then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        '';
      options.desc = "Quickfix List";
    }
    {
      key = "[q";
      mode = "n";
      action = "<cmd>cprev<cr>";
      options.desc = "Previous Quickfix";
    }
    {
      key = "]q";
      mode = "n";
      action = "<cmd>cnext<cr>";
      options.desc = "Next Quickfix";
    }

    # Float the diagnostic under the cursor
    {
      key = "<leader>cd";
      mode = "n";
      action.__raw = "vim.diagnostic.open_float";
      options.desc = "Line Diagnostics";
    }
    # ]d/[d — any severity; ]e/[e — errors only; ]w/[w — warnings only
    # float=true shows the message popup when landing on the diagnostic
    {
      key = "]d";
      mode = "n";
      action.__raw = "function() vim.diagnostic.jump({ count = vim.v.count1, float = true }) end";
      options.desc = "Next Diagnostic";
    }
    {
      key = "[d";
      mode = "n";
      action.__raw = "function() vim.diagnostic.jump({ count = -vim.v.count1, float = true }) end";
      options.desc = "Prev Diagnostic";
    }
    {
      key = "]e";
      mode = "n";
      action.__raw = "function() vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end";
      options.desc = "Next Error";
    }
    {
      key = "[e";
      mode = "n";
      action.__raw = "function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end";
      options.desc = "Prev Error";
    }
    {
      key = "]w";
      mode = "n";
      action.__raw = "function() vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end";
      options.desc = "Next Warning";
    }
    {
      key = "[w";
      mode = "n";
      action.__raw = "function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end";
      options.desc = "Prev Warning";
    }

    # Clear search, diff update and redraw
    {
      key = "<leader>ur";
      mode = "n";
      action = "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>";
      options.desc = "Redraw / Clear hlsearch / Diff Update";
    }

    # Saner n/N search behavior (https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n)
    {
      key = "n";
      mode = "n";
      action = "'Nn'[v:searchforward].'zv'";
      options.expr = true;
      options.desc = "Next Search Result";
    }
    {
      key = "n";
      mode = [
        "x"
        "o"
      ];
      action = "'Nn'[v:searchforward]";
      options.expr = true;
      options.desc = "Next Search Result";
    }
    {
      key = "N";
      mode = "n";
      action = "'nN'[v:searchforward].'zv'";
      options.expr = true;
      options.desc = "Prev Search Result";
    }
    {
      key = "N";
      mode = [
        "x"
        "o"
      ];
      action = "'nN'[v:searchforward]";
      options.expr = true;
      options.desc = "Prev Search Result";
    }

    # Tabs
    {
      key = "<leader><tab>l";
      mode = "n";
      action = "<cmd>tablast<cr>";
      options.desc = "Last Tab";
    }
    {
      key = "<leader><tab>o";
      mode = "n";
      action = "<cmd>tabonly<cr>";
      options.desc = "Close Other Tabs";
    }
    {
      key = "<leader><tab>f";
      mode = "n";
      action = "<cmd>tabfirst<cr>";
      options.desc = "First Tab";
    }
    {
      key = "<leader><tab><tab>";
      mode = "n";
      action = "<cmd>tabnew<cr>";
      options.desc = "New Tab";
    }
    {
      key = "<leader><tab>x";
      mode = "n";
      action = "<cmd>tabclose<cr>";
      options.desc = "Close Tab";
    }
    {
      key = "]<tab>";
      mode = "n";
      action = "<cmd>tabnext<cr>";
      options.desc = "Next Tab";
    }
    {
      key = "[<tab>";
      mode = "n";
      action = "<cmd>tabprevious<cr>";
      options.desc = "Previous Tab";
    }

    # Window management
    {
      key = "<C-W>x";
      mode = "n";
      action = "<cmd>close<cr>";
      options.desc = "Close Window";
    }
    {
      key = "<C-W>|";
      mode = "n";
      action = "<cmd>vsplit<cr>";
      options.desc = "Split Window Right";
    }
    {
      key = "<C-W>-";
      mode = "n";
      action = "<cmd>split<cr>";
      options.desc = "Split Window Below";
    }
    {
      key = "<C-W>s";
      mode = "n";
      action = "<C-W>x";
      options.desc = "Swap Windows";
    }

    # Disable default window resize/tab keybinds
    {
      key = "<C-W><tab>";
      mode = "n";
      action = "<Nop>";
      options.silent = true;
    }
    {
      key = "<C-W>+";
      mode = "n";
      action = "<Nop>";
      options.silent = true;
    }
    {
      key = "<C-W><";
      mode = "n";
      action = "<Nop>";
      options.silent = true;
    }
    {
      key = "<C-W>=";
      mode = "n";
      action = "<Nop>";
      options.silent = true;
    }
    {
      key = "<C-W>>";
      mode = "n";
      action = "<Nop>";
      options.silent = true;
    }
    {
      key = "<C-W>_";
      mode = "n";
      action = "<Nop>";
      options.silent = true;
    }

    # Save
    {
      key = "<C-s>";
      mode = [
        "n"
        "i"
        "x"
      ];
      action = "<cmd>w<cr><esc>";
      options.desc = "Save file";
    }

    # Undo break-points: insert <c-g>u before common punctuation so that `u`
    # only undoes back to the last ., , or ; rather than the whole paragraph
    {
      key = ",";
      mode = "i";
      action = ",<c-g>u";
    }
    {
      key = ".";
      mode = "i";
      action = ".<c-g>u";
    }
    {
      key = ";";
      mode = "i";
      action = ";<c-g>u";
    }

    # Better indenting
    {
      key = "<";
      mode = "x";
      action = "<gv";
      options.desc = "Indent left";
    }
    {
      key = ">";
      mode = "x";
      action = ">gv";
      options.desc = "Indent right";
    }

    # Move Lines
    {
      key = "<A-j>";
      mode = "n";
      action = "<cmd>execute 'move .+' . v:count1<cr>==";
      options.desc = "Move Down";
    }
    {
      key = "<A-k>";
      mode = "n";
      action = "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==";
      options.desc = "Move Up";
    }
    {
      key = "<A-j>";
      mode = "i";
      action = "<esc><cmd>m .+1<cr>==gi";
      options.desc = "Move Down";
      options.silent = true;
    }
    {
      key = "<A-k>";
      mode = "i";
      action = "<esc><cmd>m .-2<cr>==gi";
      options.desc = "Move Up";
      options.silent = true;
    }
    {
      key = "<A-j>";
      mode = "v";
      action = ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv";
      options.desc = "Move Down";
      options.silent = true;
    }
    {
      key = "<A-k>";
      mode = "v";
      action = ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv";
      options.desc = "Move Up";
      options.silent = true;
    }

    # Quit all windows/buffers in one shot
    {
      key = "<leader>qq";
      mode = "n";
      action = "<cmd>qa<cr>";
      options.desc = "Quit All";
    }
  ];
}
