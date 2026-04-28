{ inputs, ... }:
let
  nordColorscheme = ''
    return {
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
  '';

  gruvboxColorscheme = ''
    return {
      {
        "ellisonleao/gruvbox.nvim",
        name = "gruvbox",
        priority = 1000,
        lazy = false,
        opts = {
          contrast = "hard",
        },
      },

      {
        "LazyVim/LazyVim",
        opts = {
          colorscheme = "gruvbox",
        },
      },
    }
  '';

  catppuccinColorscheme = ''
    return {
      {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        lazy = false,
        opts = {
          flavour = "mocha",
        },
      },

      {
        "LazyVim/LazyVim",
        opts = {
          colorscheme = "catppuccin",
        },
      },
    }
  '';
in
{
  flake.modules.homeManager.lazyvim =
    {
      pkgs-unstable,
      config,
      lib,
      ...
    }:
    let
      colorschemeContent =
        if config.settings.colorScheme == "catppuccin-mocha" then
          catppuccinColorscheme
        else if config.settings.colorScheme == "gruvbox-dark-hard" then
          gruvboxColorscheme
        else
          nordColorscheme;
    in
    {
      stylix.targets.neovim.enable = false;

      imports = [ inputs.lazyvim-nix.homeManagerModules.default ];

      # programs.neovim.package =
      #   pkgs-unstable.lib.mkForce
      #     inputs.nixpkgs-nvim-0_11_6.legacyPackages.${pkgs-unstable.system}.neovim-unwrapped;

      programs.neovim.extraLuaPackages = ps: with ps; [ luautf8 ];

      programs.lazyvim = {
        enable = true;
        configFiles = ./nvim;
        extraPackages = with pkgs-unstable; [
          ty
          ruff
          nixd
          nixfmt
          lua-language-server
          stylua
          clang-tools
        ];
        treesitterParsers = with pkgs-unstable.vimPlugins.nvim-treesitter.grammarPlugins; [
          nix
        ];
      };

      home.file.".config/nvim/lua/plugins/colorscheme.lua".text = colorschemeContent;

      home.packages = [
        (pkgs-unstable.writeShellScriptBin "lvim" ''
          exec ${config.programs.neovim.finalPackage}/bin/nvim "$@"
        '')
      ];

      programs.zsh.shellAliases.lv = "lvim";
    };
}
