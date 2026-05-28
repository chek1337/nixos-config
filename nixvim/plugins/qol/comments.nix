{ ... }:
{
  plugins.comment = {
    enable = true;
    lazyLoad.settings.keys = [
      "gcc"
      "gbc"
      {
        __unkeyed-1 = "gc";
        mode = [
          "n"
          "x"
        ];
      }
      {
        __unkeyed-1 = "gb";
        mode = [
          "n"
          "x"
        ];
      }
    ];
  };
}
