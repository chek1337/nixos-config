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
    {
      key = "<leader>gc";
      mode = "n";
      action = "<cmd>Neogit commit<cr>";
      options.desc = "Commit popup";
    }
    {
      key = "<leader>gp";
      mode = "n";
      action = "<cmd>Neogit push<cr>";
      options.desc = "Push popup";
    }
    {
      key = "<leader>gP";
      mode = "n";
      action = "<cmd>Neogit pull<cr>";
      options.desc = "Pull popup";
    }
    {
      key = "<leader>gf";
      mode = "n";
      action = "<cmd>Neogit fetch<cr>";
      options.desc = "Fetch popup";
    }
    {
      key = "<leader>gl";
      mode = "n";
      action = "<cmd>Neogit log<cr>";
      options.desc = "Log popup";
    }
    {
      key = "<leader>gb";
      mode = "n";
      action = "<cmd>Neogit branch<cr>";
      options.desc = "Branch popup";
    }
    {
      key = "<leader>gs";
      mode = "n";
      action = "<cmd>Neogit stash<cr>";
      options.desc = "Stash popup";
    }
    {
      key = "<leader>gm";
      mode = "n";
      action = "<cmd>Neogit merge<cr>";
      options.desc = "Merge popup";
    }
    {
      key = "<leader>gr";
      mode = "n";
      action = "<cmd>Neogit rebase<cr>";
      options.desc = "Rebase popup";
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
