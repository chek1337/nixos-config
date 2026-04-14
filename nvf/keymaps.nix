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
      key = "<leader>M";
      mode = "n";
      action = "<cmd>Mason<CR>";
      desc = "Open Mason";
    }
    {
      key = "<leader>L";
      mode = "n";
      action = "<cmd>Lazy<CR>";
      desc = "Open Lazy";
    }

    {
      key = "<C-Del>";
      mode = "i";
      action = "<C-o>dw";
      desc = "Delete word forward";
    }

    {
      key = "<leader>fd";
      mode = "n";
      action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<cr>";
      desc = "Format document";
    }
    {
      key = "<leader>fd";
      mode = "v";
      action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true, range = { [\"start\"] = vim.api.nvim_buf_get_mark(0, \"<\"), [\"end\"] = vim.api.nvim_buf_get_mark(0, \">\") } })<cr>";
      desc = "Format selection";
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
  ];
}
