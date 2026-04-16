{ ... }:
{
  vim.keymaps = [
    {
      key = "<leader>gg";
      mode = "n";
      action = "<cmd>Neogit<cr>";
      desc = "Neogit";
    }
  ];

  vim.git.neogit = {
    enable = true;

    setupOpts = {
      graph_style = "kitty";

      integrations = {
        telescope = false;
        snacks = true;
        diffview = false;
        codediff = true;
      };
      diff_viewer = "codediff";
    };
  };
}
