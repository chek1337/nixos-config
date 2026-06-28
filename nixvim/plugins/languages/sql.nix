{ pkgs, config, ... }:
{
  # postgres_lsp (Supabase Postgres Language Server, Rust + libpg_query) —
  # standalone LSP для PostgreSQL: точная и быстрая диагностика синтаксиса без
  # подключения к БД. Схемные подсказки таблиц/колонок он, как и sqls, строит
  # интроспекцией живого постгреса; без коннекта их нет — к БД ходим по
  # требованию через dadbod (ниже). PG-only, что нам и нужно (migrations/PSQL).
  plugins.lsp.servers.postgres_lsp = {
    enable = true;
    # Дефолт lspconfig: workspace_required = true + root_markers =
    # [ "postgres-language-server.jsonc" ]. Без этого файла в проекте сервер не
    # стартует и к .sql-буферу не цепляется. Снимаем требование воркспейса
    # (extraOptions кладётся прямо в vim.lsp.config) и добавляем .git в маркеры —
    # standalone-диагностика синтаксиса работает без коннекта к БД, схемные
    # подсказки всё равно идут через dadbod (ниже).
    rootMarkers = [
      "postgres-language-server.jsonc"
      ".git"
    ];
    extraOptions.workspace_required = false;
  };

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    sql
  ];

  plugins.conform-nvim.settings.formatters_by_ft.sql = [ "sqlfluff" ];

  plugins.lint.lintersByFt.sql = [ "sqlfluff" ];

  # vim-dadbod — подключение к БД по требованию (:DBUI / :DB). Пока соединение
  # активно для буфера, vim-dadbod-completion отдаёт таблицы/колонки.
  plugins.vim-dadbod.enable = true;
  plugins.vim-dadbod-ui.enable = true;
  plugins.vim-dadbod-completion.enable = true;

  # Нативный blink-источник из vim-dadbod-completion (lua/.../blink.lua).
  # Источник сам активен только в sql/mysql/plsql и при отсутствии активного
  # подключения молча отдаёт пусто — для standalone-файлов безвреден.
  plugins.blink-cmp.settings.sources = {
    providers.dadbod = {
      name = "Dadbod";
      module = "vim_dadbod_completion.blink";
    };
    # per_filetype заменяет default для этих ft, поэтому перечисляем дефолтные
    # источники явно + dadbod. Так в .sql даже без БД есть keyword/word/snippet
    # комплишен (buffer/snippets/lsp), а при подключении добавляются схемные.
    per_filetype = {
      sql = [
        "dadbod"
        "lsp"
        "snippets"
        "buffer"
        "path"
      ];
      mysql = [
        "dadbod"
        "lsp"
        "snippets"
        "buffer"
        "path"
      ];
      plsql = [
        "dadbod"
        "lsp"
        "snippets"
        "buffer"
        "path"
      ];
    };
  };

  keymaps = [
    {
      key = "<leader>D";
      action = "<cmd>DBUIToggle<cr>";
      options.desc = "Toggle DBUI (dadbod)";
    }
  ];

  # postgres-language-server подтягивается автоматически модулем
  # plugins.lsp.servers.postgres_lsp; здесь только формат/линт.
  extraPackages = with pkgs; [
    sqlfluff
  ];
}
