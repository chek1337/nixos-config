{ ... }:
{
  plugins.mini-surround = {
    enable = true;
    lazyLoad.settings.keys = [
      "gs"
      "gsd"
      "gsf"
      "gsF"
      "gsh"
      "gsr"
      "gsn"
    ];
    settings = {
      mappings = {
        add = "gs";
        delete = "gsd";
        find = "gsf";
        find_left = "gsF";
        highlight = "gsh";
        replace = "gsr";
        update_n_lines = "gsn";
      };
      search_method = "cover_or_next";
      custom_surroundings = {
        c = {
          input = [ "/%*().-()%*/" ];
          output = {
            left = "/* ";
            right = " */";
          };
        };
      };
    };
  };
}
