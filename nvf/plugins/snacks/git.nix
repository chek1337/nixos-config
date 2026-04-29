{ ... }:
{
  vim.utility.snacks-nvim.setupOpts = {
    gitbrowse.enable = true;
    bufdelete.enable = true;
  };

  vim.keymaps = [
    {
      key = "<leader>bx";
      mode = [ "n" ];
      action = "function() require('snacks').bufdelete() end";
      lua = true;
      desc = "Delete Buffer";
    }
    {
      key = "<leader>bo";
      mode = [ "n" ];
      action = ''
        function()
          require('snacks').bufdelete({
            filter = function(b)
              return b ~= vim.api.nvim_get_current_buf()
                and vim.bo[b].filetype ~= "qf"
            end,
          })
        end
      '';
      lua = true;
      desc = "Delete Other Buffers";
    }
    {
      key = "<leader>gB";
      mode = [
        "n"
        "x"
      ];
      action = "function() require('snacks').gitbrowse() end";
      lua = true;
      desc = "Git Browse (open)";
    }
    {
      key = "<leader>gY";
      mode = [
        "n"
        "x"
      ];
      action = "function() require('snacks').gitbrowse({ open = function(url) vim.fn.setreg('+', url) end, notify = false }) end";
      lua = true;
      desc = "Git Browse (copy)";
    }
  ];
}
