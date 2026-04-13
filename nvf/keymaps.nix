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
  ];
}
