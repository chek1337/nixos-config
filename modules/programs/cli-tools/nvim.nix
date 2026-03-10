{inputs, ...}: {
  flake.modules.homeManager.nvim = {pkgs, ...}: {
    imports = [inputs.nvf.homeManagerModules.default];

    programs.nvf = {
      enable = true;

      settings.vim = {
        # Базовые настройки
        viAlias = true;
        vimAlias = true;

        options = {
          number = true;
          relativenumber = true;
          tabstop = 2;
          shiftwidth = 2;
          expandtab = true;
        };

        # Темы — stylix сам подхватит если включён
        theme = {
          enable = true;
          name = "nord";
          style = "dark";
        };

        # Telescope для поиска файлов
        telescope.enable = true;

        # Treesitter для подсветки
        treesitter = {
          enable = true;
          fold = true;
        };

        # LSP базовая поддержка
        lsp = {
          enable = true;
          formatOnSave = true;
        };

        # Статусная строка
        statusline.lualine.enable = true;

        # Файловое дерево
        filetree.neo-tree.enable = true;

        # Git интеграция
        git = {
          enable = true;
          gitsigns.enable = true;
        };

        # Автодополнение
        autocomplete.nvim-cmp.enable = true;

        # Языки — добавляй по необходимости
        languages = {
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = true;
          nix.enable = true;
          lua.enable = true;
        };
      };
    };
  };
}
