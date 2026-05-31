{ ... }:
{
  plugins.which-key = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
    settings = {
      preset = "helix";
      spec = [
        {
          __unkeyed-1 = "<leader>l";
          group = "LaTeX";
        }
        {
          __unkeyed-1 = "<leader>j";
          group = "Just";
        }
        {
          __unkeyed-1 = "<leader>g";
          group = "Git";
        }
        {
          __unkeyed-1 = "<leader>h";
          group = "Harpoon";
        }
        {
          __unkeyed-1 = "<leader>d";
          group = "Debug";
        }
        {
          __unkeyed-1 = "<leader>s";
          group = "Search";
        }
        {
          __unkeyed-1 = "<leader>u";
          group = "UI";
        }
        {
          __unkeyed-1 = "<leader>f";
          group = "File";
        }
        {
          __unkeyed-1 = "<leader>C";
          group = "Color";
        }
        {
          __unkeyed-1 = "<leader>b";
          group = "Buffers";
        }
        {
          __unkeyed-1 = "<leader>x";
          group = "Diagnostics";
        }
        {
          __unkeyed-1 = "<leader>m";
          group = "Multicursor";
        }
        {
          __unkeyed-1 = "<leader>c";
          group = "Code";
        }
        {
          __unkeyed-1 = "<leader><tab>";
          group = "Tabs";
        }

        {
          __unkeyed-1 = "<leader>gh";
          group = "Hunks";
        }
        {
          __unkeyed-1 = "<leader>dp";
          group = "Print";
        }
        {
          __unkeyed-1 = "<leader>gd";
          group = "Diff";
        }
        {
          __unkeyed-1 = "<leader>gC";
          group = "Conflict";
        }
        {
          __unkeyed-1 = "<leader>go";
          group = "Open";
        }
        {
          __unkeyed-1 = "<leader>gB";
          group = "Blame";
        }
        {
          __unkeyed-1 = "<leader>gdh";
          group = "History";
        }
        {
          __unkeyed-1 = "<leader>S";
          group = "Session";
        }
        {
          __unkeyed-1 = "<leader>sn";
          group = "Notifications";
        }
        {
          __unkeyed-1 = "<leader>sr";
          group = "Replace";
        }

        {
          __unkeyed-1 = "g";
          group = "Goto";
        }
        {
          __unkeyed-1 = "g?";
          group = "Debugprint";
        }
        {
          __unkeyed-1 = "gj";
          group = "Splitjoin";
        }
        {
          __unkeyed-1 = "<C-w>";
          group = "Window";
        }

        {
          __unkeyed-1 = "]";
          group = "Next";
        }
        {
          __unkeyed-1 = "[";
          group = "Prev";
        }
      ];
    };
  };
}
