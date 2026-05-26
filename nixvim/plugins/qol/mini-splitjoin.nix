{ ... }:
{
  plugins.mini-splitjoin = {
    enable = true;
    settings = {
      mappings = {
        toggle = "";
        join = "gjj";
        split = "gjs";
      };
    };
  };
}
