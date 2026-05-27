{ ... }:
{
  keymaps = [
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

    {
      key = "<C-h>";
      mode = "i";
      action = "<Left>";
    }
    {
      key = "<C-j>";
      mode = "i";
      action = "<Down>";
    }
    {
      key = "<C-k>";
      mode = "i";
      action = "<Up>";
    }
    {
      key = "<C-l>";
      mode = "i";
      action = "<Right>";
    }

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
      key = "<leader><tab>]";
      mode = "n";
      action = "<cmd>tabnext<cr>";
      options.desc = "Next Tab";
    }
    {
      key = "<leader><tab>x";
      mode = "n";
      action = "<cmd>tabclose<cr>";
      options.desc = "Close Tab";
    }
    {
      key = "<leader><tab>[";
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
    }
    {
      key = "<A-k>";
      mode = "i";
      action = "<esc><cmd>m .-2<cr>==gi";
      options.desc = "Move Up";
    }
    {
      key = "<A-j>";
      mode = "v";
      action = ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv";
      options.desc = "Move Down";
    }
    {
      key = "<A-k>";
      mode = "v";
      action = ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv";
      options.desc = "Move Up";
    }
  ];
}
