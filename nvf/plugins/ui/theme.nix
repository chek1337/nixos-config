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
      hash = "sha256-M3xH9XsWNu7f49qRI9dgfk85iQVUKCuwAYo+xORo2Wk=";
    };
  };

  themes = {
    nord = {
      package = gbprod-nord;
      # old diffadd "#1d3042"
      # old diffdelete "#351d2b"

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
    };
    "catppuccin-mocha" = # lua
      {
        package = pkgs.vimPlugins.catppuccin-nvim;
        setup = ''
          require("catppuccin").setup({
            flavour = "mocha",
            term_colors = true,
            transparent_background = false,
            show_end_of_buffer = false,
            integrations = {
              treesitter = true,
              treesitter_context = true,
              native_lsp = {
                enabled = true,
                underlines = {
                  errors = { "undercurl" },
                  hints = { "undercurl" },
                  warnings = { "undercurl" },
                  information = { "undercurl" },
                },
              },
              blink_cmp = true,
              cmp = true,
              gitsigns = true,
              diffview = true,
              telescope = { enabled = true },
              which_key = true,
              mason = true,
              noice = true,
              notify = true,
              harpoon = true,
              mini = { enabled = true },
              flash = true,
              markdown = true,
              render_markdown = true,
              alpha = true,
              bufferline = true,
              dap = true,
              dap_ui = true,
              illuminate = { enabled = true },
              indent_blankline = { enabled = true },
              lsp_trouble = true,
              snacks = { enabled = true, indent_scope_color = "lavender" },
              semantic_tokens = true,
              ts_rainbow = true,
              ts_rainbow2 = true,
              fidget = true,
              navic = { enabled = true, custom_bg = "NONE" },
            },
          })
          vim.cmd.colorscheme("catppuccin")
        '';
      };
    "gruvbox-dark-hard" = # lua
      {
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
