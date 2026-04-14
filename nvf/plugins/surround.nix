{ lib, ... }:
{
  vim.utility.surround.enable = lib.mkForce false;

  vim.mini.surround = {
    enable = true;
    setupOpts = {
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
