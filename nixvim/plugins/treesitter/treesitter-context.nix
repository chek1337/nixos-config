{ ... }:
{
  plugins.treesitter-context = {
    enable = true;
    settings = {
      enable = false;
      mode = "cursor";
    };
  };

  keymaps = [
    {
      key = "gC";
      mode = "n";
      action.__raw = "function() require('treesitter-context').go_to_context(vim.v.count1) end";
      options = {
        silent = true;
        desc = "Jump to context";
      };
    }
    {
      key = "<leader>uC";
      mode = "n";
      action = "<cmd>silent TSContext toggle<CR>";
      options.desc = "Toggle Treesitter Context";
    }
  ];
}
