{ pkgs, lib, ... }:
let
  notebook-style-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "notebook_style.nvim";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "stellarjmr";
      repo = "notebook_style.nvim";
      rev = "main";
      hash = "sha256-yLCE+6GzBp9DpRKF+8/o4ab6rG11VL1p/SKU2XtEuw8=";
    };
  };
in
{
  # vim.extraPlugins = {
  #   notebook-style-nvim = {
  #     package = notebook-style-nvim;
  #     setup = ''
  #       local scheme = vim.g.colors_name or ""
  #       local colors = scheme:find("catppuccin") and { border = "#585b70", delimiter = "#414162" }
  #                   or scheme == "gruvbox" and { border = "#504945", delimiter = "#3c3836" }
  #                   or { border = "#3b4252", delimiter = "#2e3440" }
  #       require("notebook_style").setup({
  #         colors = colors,
  #         border_style = "my_style",
  #         cell_width_percentage = 100,
  #         min_cell_width = 200,
  #         max_cell_width = 200,
  #         hide_border_in_insert = false,
  #         manual_render = false,
  #         border_chars = {
  #           my_style = {
  #             top_left = "",
  #             top_right = "",
  #             bottom_left = "",
  #             bottom_right = "",
  #             horizontal = "━",
  #             vertical = "",
  #           },
  #         },
  #       })
  #     '';
  #   };
  # };
}
