{ pkgs, ... }:
{
  # nui.nvim — общая библиотека (зависят noice и др.), оставляем в pack/start/.
  # codediff помечаем optional → попадает в pack/opt/ и грузится по `:CodeDiff`.
  extraPlugins = [
    pkgs.vimPlugins.nui-nvim
    {
      plugin = pkgs.vimPlugins.codediff-nvim;
      optional = true;
    }
  ];

  plugins.lz-n.plugins = [
    {
      __unkeyed-1 = "codediff.nvim";
      cmd = "CodeDiff";
      after = # lua
        ''
          function()
            require("codediff").setup({
              explorer = {
                position = "bottom",
                height = 10,
                file_filter = {
                  ignore = {},
                },
              },
              history = {
                position = "bottom",
                height = 10,
                file_filter = {
                  ignore = {},
                },
              },
            })
          end
        '';
    }
  ];

  keymaps = [
    {
      key = "<leader>gdd";
      mode = "n";
      action = ":CodeDiff<CR>";
      options = {
        silent = true;
        desc = "Open Codediff";
      };
    }
    {
      key = "<leader>gdD";
      mode = "n";
      action.__raw = "function() vim.fn.feedkeys(':CodeDiff ', 'n') end";
      options = {
        silent = true;
        desc = "Open Codediff to Enter Prompt";
      };
    }
    {
      key = "<leader>gdf";
      mode = "n";
      action = ":CodeDiff file HEAD<CR>";
      options = {
        silent = true;
        desc = "Open Codediff for Current File and Last Commit";
      };
    }
    {
      key = "<leader>gdF";
      mode = "n";
      action.__raw = "function() vim.fn.feedkeys(':CodeDiff file ', 'n') end";
      options = {
        silent = true;
        desc = "Open Codediff for File to Enter Prompt";
      };
    }
    {
      key = "<leader>gdhh";
      mode = "n";
      action = ":CodeDiff history<CR>";
      options = {
        silent = true;
        desc = "Open Codediff History";
      };
    }
    {
      key = "<leader>gdhH";
      mode = "n";
      action.__raw = "function() vim.fn.feedkeys(':CodeDiff history ', 'n') end";
      options = {
        silent = true;
        desc = "Open Codediff History to Enter Prompt";
      };
    }
    {
      key = "<leader>gdhf";
      mode = "n";
      action = ":CodeDiff history %<CR>";
      options = {
        silent = true;
        desc = "Open Codediff History for Current File";
      };
    }
  ];
}
