{ inputs, ... }:
{
  flake.modules.homeManager.nvf =
    { pkgs, config, ... }:
    {
      stylix.targets.neovim.enable = false;
      stylix.targets.nvf.enable = false;

      imports = [ inputs.nvf.homeManagerModules.default ];

      programs.nvf = {
        enable = true;

        settings.vim = {
          viAlias = true;
          vimAlias = true;

          theme = {
            enable = true;
            name = "nord";
            style = "dark";
          };

          opts = {
            cursorline = false;
            scrolloff = 2;
            autoread = true;
            expandtab = true;
            tabstop = 2;
            shiftwidth = 2;
            number = true;
            relativenumber = true;
            signcolumn = "yes";
          };

          globals = {
            mapleader = " ";
            maplocalleader = " ";
          };

          keymaps = [
            # Insert mode
            {
              key = "jk";
              mode = "i";
              action = "<Esc>";
              desc = "Exit insert mode with jk";
            }
            {
              key = "jj";
              mode = "i";
              action = "<Esc>";
              desc = "Exit insert mode with jj";
            }
            # Disable macros, remap to Alt+q
            {
              key = "q";
              mode = [
                "n"
                "v"
              ];
              action = "<Nop>";
              desc = "Disable macros";
            }
            {
              key = "<M-q>";
              mode = [
                "n"
                "v"
              ];
              action = "q";
              desc = "Write macros";
            }
            # Terminal
            {
              key = "<Esc>";
              mode = "t";
              action = "<C-\\><C-n>";
              desc = "Exit terminal mode";
            }
            # Paste without overwriting clipboard
            {
              key = "p";
              mode = "x";
              action = ''"_dP'';
              desc = "Paste without overwriting clipboard";
            }
            # Delete without overwriting clipboard
            {
              key = "x";
              mode = [
                "n"
                "v"
              ];
              action = ''"_x'';
              desc = "Delete char without overwriting clipboard";
            }
            # Insert mode navigation
            {
              key = "<C-h>";
              mode = "i";
              action = "<Left>";
            }
            {
              key = "<C-j>";
              mode = "i";
              action = "<Down>";
            }
            {
              key = "<C-k>";
              mode = "i";
              action = "<Up>";
            }
            {
              key = "<C-l>";
              mode = "i";
              action = "<Right>";
            }
          ];

          lsp = {
            enable = true;
            formatOnSave = false;
            trouble.enable = true;
            lspkind.enable = true;
          };

          languages = {
            enableTreesitter = true;
            enableFormat = true;

            nix = {
              enable = true;
              lsp.server = "nixd";
              format.type = "nixfmt";
            };
            lua = {
              enable = true;
            };
            python = {
              enable = true;
              lsp.server = "basedpyright";
            };
            markdown.enable = true;
            bash.enable = true;
          };

          autocomplete.blink-cmp = {
            enable = true;
          };

          snippets.luasnip.enable = true;

          autopairs.nvim-autopairs.enable = true;

          telescope.enable = true;

          git = {
            enable = true;
            gitsigns.enable = true;
          };

          visuals = {
            nvim-web-devicons.enable = true;
            fidget-nvim.enable = true;
            indent-blankline.enable = true;
            highlight-undo.enable = true;
          };

          statusline.lualine = {
            enable = true;
            theme = "nord";
          };

          tabline.nvimBufferline.enable = true;

          treesitter.context.enable = true;

          binds.whichKey.enable = true;

          ui = {
            borders.enable = true;
            noice.enable = true;
            colorizer.enable = true;
          };

          notify.nvim-notify.enable = true;

          comments.comment-nvim.enable = true;

          utility = {
            diffview-nvim.enable = true;
            surround.enable = true;
          };

          terminal.toggleterm = {
            enable = true;
            lazygit.enable = true;
          };

          extraPackages = with pkgs; [
            nixd
            nixfmt-rfc-style
            lua-language-server
            stylua
            ruff
            basedpyright
          ];
        };
      };

      programs.zsh.shellAliases = {
        v = "nvim";
      };
    };
}
