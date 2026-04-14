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
  ];
}
