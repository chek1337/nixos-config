{ pkgs, ... }:
{
  extraPackages = [ pkgs.delta ];

  extraPlugins = [ pkgs.vimPlugins.baleia-nvim ];

  extraConfigLua = ''
    vim.g.baleia = require("baleia").setup({})
  '';

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

      log_pager = [
        "delta"
        "--width"
        "117"
      ];
    };
  };
}
