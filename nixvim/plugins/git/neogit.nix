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
    {
      key = "<leader>gA";
      mode = "n";
      action = "<cmd>Neogit cherry_pick<cr>";
      options.desc = "Cherry Pick";
    }
    # {
    #   key = "<leader>gB";
    #   mode = "n";
    #   action = "<cmd>Neogit bisect<cr>";
    #   options.desc = "Bisect";
    # }
    {
      key = "<leader>gi";
      mode = "n";
      action = "<cmd>Neogit ignore<cr>";
      options.desc = "Ignore";
    }
    {
      key = "<leader>gI";
      mode = "n";
      action = "<cmd>Neogit init<cr>";
      options.desc = "Init";
    }
    {
      key = "<leader>gM";
      mode = "n";
      action = "<cmd>Neogit remote<cr>";
      options.desc = "Remote";
    }
    {
      key = "<leader>gt";
      mode = "n";
      action = "<cmd>Neogit tag<cr>";
      options.desc = "Tag";
    }
    {
      key = "<leader>gv";
      mode = "n";
      action = "<cmd>Neogit revert<cr>";
      options.desc = "Revert";
    }
    {
      key = "<leader>gw";
      mode = "n";
      action = "<cmd>Neogit worktree<cr>";
      options.desc = "Worktree";
    }
    {
      key = "<leader>gX";
      mode = "n";
      action = "<cmd>Neogit reset<cr>";
      options.desc = "Reset";
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
        show_staged_diff = true;
        staged_diff_split_kind = "split";
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
