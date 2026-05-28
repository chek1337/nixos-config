{ ... }:
{
  plugins.csvview = {
    enable = true;
    lazyLoad.settings.ft = [
      "csv"
      "tsv"
    ];
    settings = {
      view = {
        display_mode = "border";
        sticky_header.enabled = true;
      };
      keymaps = {
        textobject_field_inner = {
          __unkeyed-1 = "if";
          mode = [
            "o"
            "x"
          ];
        };
        textobject_field_outer = {
          __unkeyed-1 = "af";
          mode = [
            "o"
            "x"
          ];
        };
        jump_next_field_end = {
          __unkeyed-1 = "<Tab>";
          mode = [
            "n"
            "v"
          ];
        };
        jump_prev_field_end = {
          __unkeyed-1 = "<S-Tab>";
          mode = [
            "n"
            "v"
          ];
        };
        jump_next_row = {
          __unkeyed-1 = "<Enter>";
          mode = [
            "n"
            "v"
          ];
        };
        jump_prev_row = {
          __unkeyed-1 = "<S-Enter>";
          mode = [
            "n"
            "v"
          ];
        };
      };
    };
  };

  extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "csv", "tsv" },
      callback = function()
        vim.cmd("CsvViewEnable")
      end,
    })
  '';
}
