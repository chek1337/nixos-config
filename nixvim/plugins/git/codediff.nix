{ pkgs, ... }:
let
  # Локальный форк codediff с опцией explorer.show_untracked (только tracked
  # файлы + `git status -uno`, чтобы не вешать большие репозитории). Режим
  # теперь переключается в рантайме клавишей `gU` (toggle_untracked).
  # chek1337/codediff.nvim, ветка feat/explorer-show-untracked. Снять после мерджа PR.
  codediff-show-untracked = pkgs.vimPlugins.codediff-nvim.overrideAttrs (_: {
    src = pkgs.fetchFromGitHub {
      owner = "chek1337";
      repo = "codediff.nvim";
      rev = "63ad8d86394bfb4e1d26c94de43d07a67ee5db24";
      hash = "sha256-ozbfaVLeA9R3B2KnNxJBapbq/fhLaWQOA5qgBNkJ8pU=";
    };
  });
in
{
  # nui.nvim — общая библиотека (зависят noice и др.), оставляем в pack/start/.
  # codediff помечаем optional → попадает в pack/opt/ и грузится по `:CodeDiff`.
  extraPlugins = [
    pkgs.vimPlugins.nui-nvim
    {
      plugin = codediff-show-untracked;
      optional = true;
    }
  ];

  plugins.lz-n.plugins = [
    {
      __unkeyed-1 = "codediff.nvim";
      cmd = "CodeDiff";
      after = # lua
        ''
          function()
            require("codediff").setup({
              explorer = {
                position = "bottom",
                height = 10,
                show_untracked = false,
                file_filter = {
                  ignore = {},
                },
              },
              history = {
                position = "bottom",
                height = 10,
                file_filter = {
                  ignore = {},
                },
              },
            })
          end
        '';
    }
  ];

  keymaps = [
    {
      key = "<leader>gdd";
      mode = "n";
      action = ":CodeDiff<CR>";
      options = {
        silent = true;
        desc = "Open Codediff";
      };
    }
    {
      key = "<leader>gdD";
      mode = "n";
      action.__raw = "function() vim.fn.feedkeys(':CodeDiff ', 'n') end";
      options = {
        silent = true;
        desc = "Open Codediff to Enter Prompt";
      };
    }
    {
      key = "<leader>gdf";
      mode = "n";
      action = ":CodeDiff file HEAD<CR>";
      options = {
        silent = true;
        desc = "Open Codediff for Current File and Last Commit";
      };
    }
    {
      key = "<leader>gdF";
      mode = "n";
      action.__raw = "function() vim.fn.feedkeys(':CodeDiff file ', 'n') end";
      options = {
        silent = true;
        desc = "Open Codediff for File to Enter Prompt";
      };
    }
    {
      key = "<leader>gHh";
      mode = "n";
      action = ":CodeDiff history<CR>";
      options = {
        silent = true;
        desc = "Open Codediff History";
      };
    }
    {
      key = "<leader>gHH";
      mode = "n";
      action.__raw = "function() vim.fn.feedkeys(':CodeDiff history ', 'n') end";
      options = {
        silent = true;
        desc = "Open Codediff History to Enter Prompt";
      };
    }
    {
      key = "<leader>gHf";
      mode = "n";
      action = ":CodeDiff history %<CR>";
      options = {
        silent = true;
        desc = "Open Codediff History for Current File";
      };
    }
  ];
}
