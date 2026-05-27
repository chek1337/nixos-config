{ ... }:
{
  plugins.venv-selector = {
    enable = true;

    settings = {
      search = { };
      options = {
        picker = "snacks";
        picker_options = {
          snacks = {
            layout = {
              preset = "select";
            };
          };
        };
      };
    };
  };

  keymaps = [
    {
      key = "<localleader>v";
      mode = "n";
      action = "<cmd>VenvSelect<cr>";
      options.desc = "Select Python venv";
    }
  ];
}
