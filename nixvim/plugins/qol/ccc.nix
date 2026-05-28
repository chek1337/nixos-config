{ ... }:
{
  plugins.ccc = {
    enable = true;
    lazyLoad.settings.cmd = [
      "CccPick"
      "CccConvert"
      "CccHighlighterToggle"
      "CccHighlighterEnable"
      "CccHighlighterDisable"
    ];
    settings.highlighter = {
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
      options.desc = "Color Picker";
    }
    {
      key = "<leader>Ct";
      mode = [
        "n"
        "x"
      ];
      action = "<cmd>CccHighlighterToggle<CR>";
      options.desc = "Color Highlighter Toggle";
    }
    {
      key = "<leader>Cc";
      mode = [
        "n"
        "x"
      ];
      action = "<cmd>CccConvert<CR>";
      options.desc = "Color Convert";
    }
  ];
}
