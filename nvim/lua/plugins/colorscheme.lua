return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
      flavour = "mocha",
      color_overrides = {
        mocha = {
          rosewater = "#f5e0dc",
          flamingo = "#f2cdcd",
          pink = "#f5c2e7",
          mauve = "#cba6f7",
          red = "#f38ba8",
          maroon = "#eba0ac",
          peach = "#fab387",
          yellow = "#f9e2af",
          green = "#a6e3a1",
          teal = "#94e2d5",
          sky = "#89dceb",
          sapphire = "#74c7ec",
          blue = "#89b4fa",
          lavender = "#b4befe",
          text = "#cdd6f4",
          subtext1 = "#bac2de",
          subtext0 = "#a6adc8",
          overlay2 = "#9399b2",
          overlay1 = "#7f849c",
          overlay0 = "#6c7086",
          surface2 = "#585b70",
          surface1 = "#45475a",
          surface0 = "#313244",
          base = "#1e1e2e",
          mantle = "#181825",
          crust = "#11111b",
        },
      },
    },
  },

  {
    "gbprod/nord.nvim",
    name = "nord",
    lazy = false,
    priority = 1000,
    config = function()
      require("nord").setup({
        on_highlights = function(highlights, colors)
          highlights.DiffAdd = {
            bg = "#1d3042",
          } -- #1d3042 /  #2b342c / #30392f / #394545 / #444f44
          --
          highlights.DiffDelete = {
            bg = "#351d2b",
          } -- #351d2b / #582a33
        end,
      })
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#282d37" })
          vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#282d37" })
        end,
      })
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },
}
