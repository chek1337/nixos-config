{ pkgs, ... }:
{
  vim.extraPackages = [ pkgs.texliveMedium ];

  vim.globals = {
    vimtex_view_method = "zathura";
    vimtex_compiler_method = "latexmk";
    # disable insert-mode mappings — conflicts with completion
    vimtex_imaps_enabled = 0;
    # suppress warnings about missing compiler/viewer on non-tex files
    vimtex_quickfix_mode = 0;
  };

  vim.extraPlugins = with pkgs.vimPlugins; {
    vimtex = {
      package = vimtex;
      setup = # lua
        ''
          -- vimtex is configured entirely via vim.g.* above; no setup() call needed.
          -- localleader = \, so compilation is \ll, view is \lv, clean is \lc, etc.
        '';
    };
  };
}
