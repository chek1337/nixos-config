{
  pkgs,
  lib,
  colorScheme,
  ...
}:
let
  gbprod-nord = pkgs.vimUtils.buildVimPlugin {
    pname = "nord.nvim";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "gbprod";
      repo = "nord.nvim";
      rev = "main";
      hash = "sha256-+nZb7P2z4S26amtguGAvAevf60Dn/uniSVZvR0DM+zw=";
    };
  };

  themes = {
    nord = {
      package = gbprod-nord;
      setup = ''
        require("nord").setup({
          on_highlights = function(highlights, colors)
            highlights.DiffAdd = { bg = "#1d3042" }
            highlights.DiffDelete = { bg = "#351d2b" }
          end,
        })
        vim.api.nvim_create_autocmd("ColorScheme", {
          pattern = "*",
          callback = function()
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#282d37" })
            vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#282d37" })
          end,
        })
        vim.cmd.colorscheme("nord")
      '';
    };
    "catppuccin-mocha" = {
      package = pkgs.vimPlugins.catppuccin-nvim;
      setup = ''
        require("catppuccin").setup({ flavour = "mocha" })
        vim.cmd.colorscheme("catppuccin")
      '';
    };
    "gruvbox-dark-hard" = {
      package = pkgs.vimPlugins.gruvbox-nvim;
      setup = ''
        require("gruvbox").setup({ contrast = "hard" })
        vim.cmd.colorscheme("gruvbox")
      '';
    };
  };

  theme = themes.${colorScheme} or null;
in
{
  vim.extraPlugins = lib.optionalAttrs (theme != null) { colorscheme = theme; };
}
