{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    venv-selector-nvim = {
      package = venv-selector-nvim;
      setup = # lua
        ''
          require("venv-selector").setup({
            search = {},
            options = {
              picker = "snacks",
              picker_options = {
                snacks = {
                  layout = {
                    preset = "select",
                  },
                },
              },
            },
          })
        '';
    };
  };

  vim.keymaps = [
    {
      key = "<localleader>v";
      mode = [ "n" ];
      action = "<cmd>VenvSelect<cr>";
      desc = "Select Python venv";
    }
  ];
}
