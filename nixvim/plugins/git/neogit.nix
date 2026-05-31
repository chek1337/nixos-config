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
      options.desc = "Commit";
    }
    {
      key = "<leader>gp";
      mode = "n";
      action = "<cmd>Neogit push<cr>";
      options.desc = "Push";
    }
    {
      key = "<leader>gP";
      mode = "n";
      action = "<cmd>Neogit pull<cr>";
      options.desc = "Pull";
    }
    {
      key = "<leader>gf";
      mode = "n";
      action = "<cmd>Neogit fetch<cr>";
      options.desc = "Fetch";
    }
    {
      key = "<leader>gl";
      mode = "n";
      action = "<cmd>Neogit log<cr>";
      options.desc = "Log";
    }
    {
      key = "<leader>gb";
      mode = "n";
      action = "<cmd>Neogit branch<cr>";
      options.desc = "Branch";
    }
    {
      key = "<leader>gs";
      mode = "n";
      action = "<cmd>Neogit stash<cr>";
      options.desc = "Stash";
    }
    {
      key = "<leader>gm";
      mode = "n";
      action = "<cmd>Neogit merge<cr>";
      options.desc = "Merge";
    }
    {
      key = "<leader>gr";
      mode = "n";
      action = "<cmd>Neogit rebase<cr>";
      options.desc = "Rebase";
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
        codediff = false;
      };

      commit_editor = {
        show_staged_diff = false;
        staged_diff_split_kind = "floating";
        spell_check = false;
      };

      log_pager = [
        "delta"
        "--width"
        "117"
      ];
    };
  };
}
