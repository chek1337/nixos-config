{ pkgs }:
let
  gbprod-nord = pkgs.vimUtils.buildVimPlugin {
    pname = "nord.nvim";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "gbprod";
      repo = "nord.nvim";
      rev = "main";
      hash = "sha256-M3xH9XsWNu7f49qRI9dgfk85iQVUKCuwAYo+xORo2Wk=";
    };
  };
in
{
  # old diffadd "#1d3042"
  # old diffdelete "#351d2b"
  package = gbprod-nord;

  setup = # lua
    ''
      require("nord").setup({
        on_highlights = function(highlights, colors)
          highlights.DiffAdd = { bg = "#022800" }
          highlights.DiffDelete = { bg = "#3d0100" }
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
}
