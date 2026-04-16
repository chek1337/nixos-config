{ ... }:
{
  vim.binds.whichKey = {
    enable = true;
    setupOpts = {
      preset = "helix";
    };
    register = {
      "<leader>g" = "Git";
      "<leader>h" = "Harpoon";
      "<leader>d" = "Debug";
      "<leader>s" = "Search";
      "<leader>u" = "UI";
      "<leader>f" = "File";
      "<leader>C" = "Color";
      "<leader>b" = "Buffers";
      "<leader>x" = "Diagnostics";
      "<leader><tab>" = "Tabs";

      "<leader>gh" = "Hunks";
      "<leader>dp" = "Print";
      "<leader>gd" = "Diff";
      "<leader>gdh" = "History";
      "<leader>S" = "Session";
      "<leader>sn" = "Notifications";
      "<leader>sr" = "Replace";

      "]" = "Next";
      "[" = "Prev";
    };
  };
}
