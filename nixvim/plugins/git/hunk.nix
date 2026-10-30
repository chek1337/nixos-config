{ hunkEditorPkg, ... }:
let
  editor = "${hunkEditorPkg}/libexec/hunk-editor/nvim";
in
{
  # Связка с hunk (https://github.com/modem-dev/hunk) без перезапуска LSP на
  # каждое открытие файла. Обёртка $EDITOR — packages/hunk-editor.sh, она зовёт
  # HunkOpen отсюда двумя путями:
  #   * <leader>gdh — hunk во float-терминале, `e` прячет float и открывает файл
  #     в этом же nvim (LSP уже прогрет);
  #   * `hunk` из шелла — обёртка держит headless-сервер nvim на репо
  #     (HUNK_NVIM_SERVER=1) и цепляет к нему UI. Ниже для такого сервера
  #     `:q` из последнего окна делает :detach, так что сервер и LSP живут
  #     дальше; `:qa` гасит сервер.
  extraConfigLua = ''
    do
      local hunk_term

      function _G.HunkOpen(file, line)
        vim.schedule(function()
          if hunk_term and hunk_term:win_valid() then
            hunk_term:hide()
          end
          vim.cmd("drop " .. vim.fn.fnameescape(file))
          pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
          vim.cmd("normal! zz")
        end)
        return 0
      end

      vim.keymap.set("n", "<leader>gdh", function()
        hunk_term = require("snacks").terminal.toggle({ "hunk", "diff" }, {
          cwd = require("snacks").git.get_root(),
          env = { EDITOR = "${editor}" },
          win = { position = "float", width = 0.95, height = 0.95, border = "rounded" },
        })
      end, { desc = "Hunk (review diff)" })

      if vim.env.HUNK_NVIM_SERVER then
        -- Не наследовать в дочерние процессы (терминалы внутри сервера).
        vim.env.HUNK_NVIM_SERVER = nil

        -- Выход из последнего окна (:q, :wq, :x, ZZ, ZQ) отцепляет UI вместо
        -- завершения сервера: в QuitPre подкладываем ещё одно окно, чтобы :q
        -- закрыл только текущее, и затем делаем :detach. Аббревиатуры на :q
        -- не годятся — <CR> при открытом меню blink.cmp их обходит. :qa
        -- по-прежнему гасит сервер целиком.
        vim.api.nvim_create_autocmd("QuitPre", {
          callback = function()
            if #vim.api.nvim_list_tabpages() > 1 then return end
            local n = 0
            for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              if vim.api.nvim_win_get_config(w).relative == "" then n = n + 1 end
            end
            if n > 1 then return end
            vim.cmd("split")
            vim.schedule(function() pcall(vim.cmd, "detach") end)
          end,
        })

        -- Сервер не должен перезаписывать обычную сессию проекта (persistence
        -- автосейвит на VimLeavePre; наш autocmd зарегистрирован раньше).
        vim.api.nvim_create_autocmd("VimLeavePre", {
          callback = function()
            if package.loaded["persistence"] then
              require("persistence").stop()
            end
          end,
        })

        -- Гасим сервер после 30 минут без подключённого UI (если есть
        -- несохранённые буферы — тогда :qall откажет и сервер останется).
        local idle = vim.uv.new_timer()
        local function arm()
          idle:start(30 * 60 * 1000, 0, vim.schedule_wrap(function()
            if #vim.api.nvim_list_uis() == 0 then
              pcall(vim.cmd, "qall")
            end
          end))
        end
        vim.api.nvim_create_autocmd("UIEnter", { callback = function() idle:stop() end })
        vim.api.nvim_create_autocmd("UILeave", { callback = arm })
        arm()
      end
    end
  '';
}
