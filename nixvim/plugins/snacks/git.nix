{ ... }:
{
  plugins.snacks.settings = {
    gitbrowse.enabled = true;
    bufdelete.enabled = true;
  };

  keymaps = [
    {
      key = "<leader>gob";
      mode = [
        "n"
        "x"
      ];
      action.__raw = "function() require('snacks').gitbrowse() end";
      options.desc = "Git Browse (open)";
    }
    {
      key = "<leader>goy";
      mode = [
        "n"
        "x"
      ];
      action.__raw = "function() require('snacks').gitbrowse({ open = function(url) vim.fn.setreg('+', url) end, notify = false }) end";
      options.desc = "Git Browse (copy)";
    }
  ];
}
