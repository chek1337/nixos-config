{ ... }:
{
  plugins.mini-splitjoin = {
    enable = true;
    lazyLoad.settings.keys = [
      "gjj"
      "gjs"
    ];
    settings = {
      mappings = {
        toggle = "";
        join = "gjj";
        split = "gjs";
      };
    };
  };
}
