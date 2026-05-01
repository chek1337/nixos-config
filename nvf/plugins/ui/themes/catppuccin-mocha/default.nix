{ pkgs }:
{
  package = pkgs.vimPlugins.catppuccin-nvim;

  setup = # lua
    ''
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
}
