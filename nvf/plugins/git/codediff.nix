{ pkgs, ... }:
{
  vim = {
    extraPlugins = with pkgs.vimPlugins; {
      nui-nvim = {
        package = nui-nvim;
      };

      codediff-nvim = {
        package = codediff-nvim;
        after = [ "nui-nvim" ];
        setup = ''
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
        '';
      };
    };

    keymaps = [
      {
        key = "<leader>gdd";
        mode = [ "n" ];
        action = ":CodeDiff<CR>";
        silent = true;
        desc = "Open Codediff";
      }
      {
        key = "<leader>gdD";
        mode = [ "n" ];
        action = "function() vim.fn.feedkeys(':CodeDiff ', 'n') end";
        lua = true;
        silent = true;
        desc = "Open Codediff to Enter Prompt";
      }
      {
        key = "<leader>gdf";
        mode = [ "n" ];
        action = ":CodeDiff file HEAD<CR>";
        silent = true;
        desc = "Open Codediff for Current File and Last Commit";
      }
      {
        key = "<leader>gdF";
        mode = [ "n" ];
        action = "function() vim.fn.feedkeys(':CodeDiff file ', 'n') end";
        lua = true;
        silent = true;
        desc = "Open Codediff for File to Enter Prompt";
      }
      {
        key = "<leader>gdhh";
        mode = [ "n" ];
        action = ":CodeDiff history<CR>";
        silent = true;
        desc = "Open Codediff History";
      }
      {
        key = "<leader>gdhH";
        mode = [ "n" ];
        action = "function() vim.fn.feedkeys(':CodeDiff history ', 'n') end";
        lua = true;
        silent = true;
        desc = "Open Codediff History to Enter Prompt";
      }
      {
        key = "<leader>gdhf";
        mode = [ "n" ];
        action = ":CodeDiff history %<CR>";
        silent = true;
        desc = "Open Codediff History for Current File";
      }
    ];
  };
}
