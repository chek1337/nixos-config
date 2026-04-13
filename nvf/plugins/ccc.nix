{ ... }:
{
  vim = {
    utility.ccc = {
      enable = true;
      setupOpts.highlighter = {
        auto_enable = true;
        lsp = true;
      };
    };

    keymaps = [
      {
        key = "<leader>Cp";
        mode = [
          "n"
          "x"
        ];
        action = "<cmd>CccPick<CR>";
        desc = "Color Picker";
      }
      {
        key = "<leader>Ct";
        mode = [
          "n"
          "x"
        ];
        action = "<cmd>CccHighlighterToggle<CR>";
        desc = "Color Highlighter Toggle";
      }
      {
        key = "<leader>Cc";
        mode = [
          "n"
          "x"
        ];
        action = "<cmd>CccConvert<CR>";
        desc = "Color Convert";
      }
    ];
  };
}
