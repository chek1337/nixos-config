{ ... }:
{
  keymaps = [
    {
      key = "<leader>gg";
      mode = "n";
      action = "<cmd>Neogit<cr>";
      options.desc = "Neogit";
    }
  ];

  plugins.neogit = {
    enable = true;
    lazyLoad.settings.cmd = "Neogit";

    settings = {
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
