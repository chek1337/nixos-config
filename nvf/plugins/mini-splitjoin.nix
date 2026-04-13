{ ... }:
{
  vim.mini.splitjoin = {
    enable = true;
    setupOpts = {
      mappings = {
        toggle = "";
        join = "gjj";
        split = "gjs";
      };
    };
  };
}
