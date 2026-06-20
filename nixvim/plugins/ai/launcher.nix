{
  # Рантайм-резолвер обёртки запуска для AI-серверов (copilot LSP — ai/copilot.nix,
  # avante ACP — ai/avante.nix). Раньше vopono был ЗАШИТ в nix через voponoWgSecret;
  # теперь способ обёртки решается ПРИ ЗАПУСКЕ nvim, без пересборки — так один и тот
  # же бинарь работает на NixOS-хостах (через vopono), в standalone .#nvim и на
  # чужой машине (Ubuntu и т.п.) со своим туннелем или вовсе без него.
  #
  # Кладём чистый lua-модуль на runtimepath (require("ai_launcher")); сам файл
  # статичный, поэтому require доступен в любой момент инициализации (в т.ч. когда
  # строится таблица vim.lsp.config / avante acp_providers через __raw).
  #
  # ===========================================================================
  # КАК ЭТИМ ПОЛЬЗОВАТЬСЯ
  # ===========================================================================
  #
  # Резолвер ищет «обёртку запуска» в таком порядке (первое найденное побеждает):
  #   1. $NVIM_AI_WRAPPER  — путь к исполняемому файлу. Разовое/ad-hoc решение
  #                          «на этот запуск nvim». Перекрывает файл из п.2.
  #   2. ~/.config/nvim-ai/wrapper  — постоянная обёртка для этой машины/юзера.
  #   3. (ничего не найдено)  — ПРЯМОЙ запуск сервера, без туннеля.
  #
  # Обёртка — это обычный исполняемый скрипт. На вход (argv) ей приходит ПОЛНАЯ
  # команда сервера, а она запускает её через нужный туннель. Один и тот же
  # скрипт используется и для copilot, и для avante:
  #   copilot → `copilot-language-server --stdio`   (2 аргумента)
  #   avante  → `claude-agent-acp`                    (1 аргумент)
  #
  # ВАЖНО про кавычки в скрипте:
  #   • vopono берёт <APPLICATION> ОДНОЙ строкой → склеиваем: "$*"
  #   • туннели типа sshuttle/proxychains берут argv как есть → "$@"
  #
  # --- Вариант А: на NixOS-хостах (desktop/laptop) ----------------------------
  # Ничего делать не нужно. Дефолтный ~/.config/nvim-ai/wrapper с vopono и
  # wg-секретом хоста генерится декларативно из nixvim/nixvim.nix (home.file).
  # Поведение «всё через vopono» сохраняется как раньше.
  #
  # --- Вариант Б: standalone .#nvim / чужая машина (Ubuntu и т.п.) -------------
  # По умолчанию — прямой запуск. Чтобы пустить через туннель:
  #
  #   Разово (приоритетнее файла):
  #     NVIM_AI_WRAPPER=~/ai-wrapper.sh nvim
  #
  #   Постоянно — создать исполняемый ~/.config/nvim-ai/wrapper, например:
  #
  #     # vopono (склейка в один аргумент через "$*")
  #     #!/bin/sh
  #     exec vopono exec --protocol wireguard --custom /path/wg.conf "$*"
  #
  #     # любой другой туннель (argv как есть через "$@")
  #     #!/bin/sh
  #     exec sshuttle -r vpn 0/0 -- "$@"
  #
  #   Не забыть: chmod +x ~/.config/nvim-ai/wrapper
  #
  # --- Проверить, что применилось ---------------------------------------------
  #   :lua print(vim.inspect(require("ai_launcher").wrap({ "echo", "hi" })))
  # Покажет итоговую команду: с префиксом-обёрткой (туннель активен) либо
  # как есть (прямой запуск). Если NVIM_AI_WRAPPER указывает на неисполняемый
  # файл — придёт WARN-нотификация и резолвер откатится к файлу/прямому запуску.
  # ===========================================================================
  extraFiles."lua/ai_launcher.lua".text = ''
    -- ai_launcher: где взять «рецепт запуска» AI-серверов в рантайме.
    -- Порядок: $NVIM_AI_WRAPPER (путь к исполняемой обёртке) →
    -- ~/.config/nvim-ai/wrapper → прямой запуск. Обёртка получает ПОЛНУЮ команду
    -- сервера как argv и сама отвечает за tool-specific кавычки: vopono берёт
    -- приложение ОДНОЙ строкой, поэтому внутри vopono-скрипта используем "$*";
    -- туннели вроде sshuttle берут argv как есть → "$@".
    local M = {}

    local function resolve()
      local env = vim.env.NVIM_AI_WRAPPER
      if env and env ~= "" then
        if vim.fn.executable(env) == 1 then
          return env
        end
        vim.notify("NVIM_AI_WRAPPER задан, но не исполняемый: " .. env, vim.log.levels.WARN)
        return nil
      end
      local default = vim.fn.expand("~/.config/nvim-ai/wrapper")
      if vim.fn.executable(default) == 1 then
        return default
      end
      return nil
    end

    -- Оборачивает команду сервера (список) резолвнутой обёрткой; нет обёртки —
    -- возвращает команду как есть (прямой запуск).
    function M.wrap(argv)
      local wrapper = resolve()
      if not wrapper then
        return argv
      end
      local cmd = { wrapper }
      vim.list_extend(cmd, argv)
      return cmd
    end

    -- Для API, где command и args нужны раздельно (avante acp_providers).
    function M.command(argv)
      return M.wrap(argv)[1]
    end

    function M.args(argv)
      return vim.list_slice(M.wrap(argv), 2)
    end

    return M
  '';
}
