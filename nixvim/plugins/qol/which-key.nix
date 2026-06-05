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
          __unkeyed-1 = "<leader>o";
          group = "Overseer";
        }
        {
          __unkeyed-1 = "<leader>c";
          group = "Code";
        }
        {
          __unkeyed-1 = "<leader>r";
          group = "Refactor";
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
          __unkeyed-1 = "<leader>gH";
          group = "History";
        }
        {
          __unkeyed-1 = "<leader>q";
          group = "Quit";
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
          __unkeyed-1 = "<C-w>m";
          group = "Move";
        }
        {
          __unkeyed-1 = "<C-w>r";
          group = "Resize";
        }

        # Hide default <C-w> bindings that are unused given the current setup:
        # H/J/K/L  — move window to far edge  (covered by <C-w>m move mode)
        # T        — break window out to a new tab
        # v        — vertical split             (user has <C-w>|)
        # w        — cycle windows              (user navigates with h/j/k/l)
        # < > + =_ — manual resize/equalize     (covered by <C-w>r resize mode)
        # D        — built-in diagnostic float  (user has <leader>cd)
        {
          __unkeyed-1 = "<C-w>H";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w>J";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w>K";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w>L";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w>T";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w>v";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w>w";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w><lt>";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w>>";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w>+";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w>=";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w>_";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w>D";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w>d";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w><C-d>";
          hidden = true;
        }
        {
          __unkeyed-1 = "<C-w><Tab>";
          hidden = true;
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
