{ ... }:
{
  vim.keymaps = [
    {
      key = "jk";
      mode = "i";
      action = "<Esc>";
      desc = "Exit insert mode with jk";
    }
    {
      key = "jj";
      mode = "i";
      action = "<Esc>";
      desc = "Exit insert mode with jj";
    }

    {
      key = "q";
      mode = [
        "n"
        "v"
      ];
      action = "<Nop>";
      desc = "Disable macros";
    }
    {
      key = "<M-q>";
      mode = [
        "n"
        "v"
      ];
      action = "q";
      desc = "Write macros";
    }

    {
      key = "<Esc>";
      mode = "t";
      action = "<C-\\><C-n>";
      desc = "Exit terminal mode";
    }

    {
      key = "p";
      mode = "x";
      action = ''"_dP'';
      desc = "Paste without overwriting clipboard";
    }

    {
      key = "x";
      mode = [
        "n"
        "v"
      ];
      action = ''"_x'';
      desc = "Delete char without overwriting clipboard";
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
      desc = "Previous buffer";
    }
    {
      key = "K";
      mode = "n";
      action = "<cmd>BufferLineCycleNext<cr>";
      desc = "Next buffer";
    }

    {
      key = "gh";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.hover()<cr>";
      desc = "LSP Hover";
    }

    {
      key = "H";
      mode = "n";
      action = "<Nop>";
      silent = true;
    }
    {
      key = "L";
      mode = "n";
      action = "<Nop>";
      silent = true;
    }

    {
      key = "<C-Del>";
      mode = "i";
      action = "<C-o>dw";
      desc = "Delete word forward";
    }

    # Quickfix list
    {
      key = "<leader>xq";
      mode = "n";
      lua = true;
      action = ''
        function()
          local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
          if not success and err then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      '';
      desc = "Quickfix List";
    }
    {
      key = "[q";
      mode = "n";
      action = "<cmd>cprev<cr>";
      desc = "Previous Quickfix";
    }
    {
      key = "]q";
      mode = "n";
      action = "<cmd>cnext<cr>";
      desc = "Next Quickfix";
    }

    # Clear search, diff update and redraw
    {
      key = "<leader>ur";
      mode = "n";
      action = "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>";
      desc = "Redraw / Clear hlsearch / Diff Update";
    }

    # Saner n/N search behavior (https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n)
    {
      key = "n";
      mode = "n";
      action = "'Nn'[v:searchforward].'zv'";
      expr = true;
      desc = "Next Search Result";
    }
    {
      key = "n";
      mode = [
        "x"
        "o"
      ];
      action = "'Nn'[v:searchforward]";
      expr = true;
      desc = "Next Search Result";
    }
    {
      key = "N";
      mode = "n";
      action = "'nN'[v:searchforward].'zv'";
      expr = true;
      desc = "Prev Search Result";
    }
    {
      key = "N";
      mode = [
        "x"
        "o"
      ];
      action = "'nN'[v:searchforward]";
      expr = true;
      desc = "Prev Search Result";
    }

    # Tabs
    {
      key = "<leader><tab>l";
      mode = "n";
      action = "<cmd>tablast<cr>";
      desc = "Last Tab";
    }
    {
      key = "<leader><tab>o";
      mode = "n";
      action = "<cmd>tabonly<cr>";
      desc = "Close Other Tabs";
    }
    {
      key = "<leader><tab>f";
      mode = "n";
      action = "<cmd>tabfirst<cr>";
      desc = "First Tab";
    }
    {
      key = "<leader><tab><tab>";
      mode = "n";
      action = "<cmd>tabnew<cr>";
      desc = "New Tab";
    }
    {
      key = "<leader><tab>]";
      mode = "n";
      action = "<cmd>tabnext<cr>";
      desc = "Next Tab";
    }
    {
      key = "<leader><tab>d";
      mode = "n";
      action = "<cmd>tabclose<cr>";
      desc = "Close Tab";
    }
    {
      key = "<leader><tab>[";
      mode = "n";
      action = "<cmd>tabprevious<cr>";
      desc = "Previous Tab";
    }

    # Window management
    {
      key = "<C-W>x";
      mode = "n";
      action = "<cmd>close<cr>";
      desc = "Close Window";
    }
    {
      key = "<C-W>|";
      mode = "n";
      action = "<cmd>vsplit<cr>";
      desc = "Split Window Right";
    }
    {
      key = "<C-W>-";
      mode = "n";
      action = "<cmd>split<cr>";
      desc = "Split Window Below";
    }
    {
      key = "<C-W>s";
      mode = "n";
      action = "<C-W>x";
      desc = "Swap Windows";
    }

    # Disable default window resize/tab keybinds
    {
      key = "<C-W><tab>";
      mode = "n";
      action = "<Nop>";
      silent = true;
    }
    {
      key = "<C-W>+";
      mode = "n";
      action = "<Nop>";
      silent = true;
    }
    {
      key = "<C-W><";
      mode = "n";
      action = "<Nop>";
      silent = true;
    }
    {
      key = "<C-W>=";
      mode = "n";
      action = "<Nop>";
      silent = true;
    }
    {
      key = "<C-W>>";
      mode = "n";
      action = "<Nop>";
      silent = true;
    }
    {
      key = "<C-W>_";
      mode = "n";
      action = "<Nop>";
      silent = true;
    }

    # Better indenting
    {
      key = "<";
      mode = "x";
      action = "<gv";
      desc = "Indent left";
    }
    {
      key = ">";
      mode = "x";
      action = ">gv";
      desc = "Indent right";
    }

    # Move Lines
    {
      key = "<A-j>";
      mode = "n";
      action = "<cmd>execute 'move .+' . v:count1<cr>==";
      desc = "Move Down";
    }
    {
      key = "<A-k>";
      mode = "n";
      action = "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==";
      desc = "Move Up";
    }
    {
      key = "<A-j>";
      mode = "i";
      action = "<esc><cmd>m .+1<cr>==gi";
      desc = "Move Down";
    }
    {
      key = "<A-k>";
      mode = "i";
      action = "<esc><cmd>m .-2<cr>==gi";
      desc = "Move Up";
    }
    {
      key = "<A-j>";
      mode = "v";
      action = ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv";
      desc = "Move Down";
    }
    {
      key = "<A-k>";
      mode = "v";
      action = ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv";
      desc = "Move Up";
    }

    {
      key = "<leader>cf";
      mode = "n";
      action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<cr>";
      desc = "Format document";
    }
    {
      key = "<leader>cF";
      mode = [
        "n"
        "x"
      ];
      lua = true;
      action = "function() require('conform').format({ formatters = { 'injected' }, timeout_ms = 3000 }) end";
      desc = "Format Injected Langs";
    }
    {
      key = "<leader>cf";
      mode = "v";
      action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true, range = { [\"start\"] = vim.api.nvim_buf_get_mark(0, \"<\"), [\"end\"] = vim.api.nvim_buf_get_mark(0, \">\") } })<cr>";
      desc = "Format selection";
    }

    # LSP code actions
    {
      key = "<leader>ca";
      mode = [
        "n"
        "x"
      ];
      lua = true;
      action = "function() vim.lsp.buf.code_action() end";
      desc = "Code Action";
    }
    {
      key = "<leader>cr";
      mode = "n";
      lua = true;
      action = "function() vim.lsp.buf.rename() end";
      desc = "Rename";
    }
    {
      key = "<leader>cR";
      mode = "n";
      lua = true;
      action = ''
        function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          for _, client in ipairs(clients) do
            if client:supports_method("workspace/willRenameFiles")
              or client:supports_method("workspace/didRenameFiles") then
              require('snacks').rename.rename_file()
              return
            end
          end
          vim.notify("LSP does not support file rename", vim.log.levels.WARN)
        end
      '';
      desc = "Rename File";
    }
    {
      key = "<leader>cc";
      mode = [
        "n"
        "x"
      ];
      lua = true;
      action = "function() vim.lsp.codelens.run() end";
      desc = "Run Codelens";
    }
    {
      key = "<leader>cC";
      mode = "n";
      lua = true;
      action = "function() vim.lsp.codelens.refresh() end";
      desc = "Refresh & Display Codelens";
    }

    # Diagnostic virtual lines
    {
      key = "<leader>udd";
      mode = "n";
      lua = true;
      action = ''
        function()
          local cfg = vim.diagnostic.config()
          local virt = cfg.virtual_lines

          if type(virt) == "table" and virt.current_line then
            vim.diagnostic.config({ virtual_lines = false })
          else
            vim.diagnostic.config({ virtual_lines = { current_line = true } })
          end
        end
      '';
      desc = "Toggle virtual lines for current line only";
    }
    {
      key = "<leader>udD";
      mode = "n";
      lua = true;
      action = ''
        function()
          local cfg = vim.diagnostic.config()
          local virt = cfg.virtual_lines

          if virt == true or (type(virt) == "table" and not virt.current_line) then
            vim.diagnostic.config({ virtual_lines = false })
          else
            vim.diagnostic.config({ virtual_lines = true })
          end
        end
      '';
      desc = "Toggle full virtual lines";
    }
  ];
}
