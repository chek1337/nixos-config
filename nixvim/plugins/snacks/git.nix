{ ... }:
{
  plugins.snacks.settings = {
    gitbrowse.enabled = true;
    bufdelete.enabled = true;
  };

  keymaps = [
    {
      key = "<leader>bx";
      mode = "n";
      action.__raw = "function() require('snacks').bufdelete() end";
      options.desc = "Delete Buffer";
    }
    {
      key = "<leader>bo";
      mode = "n";
      action.__raw = ''
        function()
          require('snacks').bufdelete({
            filter = function(b)
              return b ~= vim.api.nvim_get_current_buf()
                and vim.bo[b].filetype ~= "qf"
            end,
          })
        end
      '';
      options.desc = "Delete Other Buffers";
    }
    {
      key = "<leader>gB";
      mode = [
        "n"
        "x"
      ];
      action.__raw = "function() require('snacks').gitbrowse() end";
      options.desc = "Git Browse (open)";
    }
    {
      key = "<leader>gY";
      mode = [
        "n"
        "x"
      ];
      action.__raw = "function() require('snacks').gitbrowse({ open = function(url) vim.fn.setreg('+', url) end, notify = false }) end";
      options.desc = "Git Browse (copy)";
    }
  ];
}
