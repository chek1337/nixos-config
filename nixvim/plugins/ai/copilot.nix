{
  pkgs,
  ...
}:
let
  copilotLs = "${pkgs.copilot-language-server}/bin/copilot-language-server";
in
{
  # GitHub Copilot как НАТИВНЫЙ LSP (copilot-language-server из nixpkgs), а не
  # через copilot.lua/Node. Даёт:
  #   • inline-completion (мультистрочный ghost text) через
  #     vim.lsp.inline_completion (Neovim 0.12+);
  #   • «движок» для Next Edit Suggestion в sidekick (см. ai/sidekick.nix).
  #
  # Используем новый модуль `lsp.servers.*` (vim.lsp.config/enable), а не легаси
  # `plugins.lsp.servers.*` (там copilot нет — это не обычный LSP). nixvim НЕ
  # везёт lsp/copilot.lua из nvim-lspconfig, поэтому cmd/init_options прописываем
  # сами. copilot-language-server обязательно требует editorInfo/editorPluginInfo,
  # иначе сервер не стартует. cmd считаем В РАНТАЙМЕ через ai_launcher
  # (ai/launcher.nix): на хостах он завернёт сервер в vopono, в standalone/на
  # чужой машине — прямой запуск или свой туннель ($NVIM_AI_WRAPPER / файл).
  lsp.servers.copilot = {
    enable = true;
    config = {
      cmd.__raw = ''require("ai_launcher").wrap({ "${copilotLs}", "--stdio" })'';
      # root_dir вместо root_markers — это наш «выключатель»: пока Copilot выключен
      # (_G.copilot_enabled = false, ставится в extraConfigLua), функция НЕ зовёт
      # on_dir, поэтому vim.lsp клиента не создаёт вообще => сервер (и vopono из
      # ai/launcher.nix) не поднимается. Когда включён — ведём себя как старый
      # root_markers = [".git"]: стартуем только внутри git-репозитория.
      root_dir.__raw = ''
        function(bufnr, on_dir)
          if not _G.copilot_enabled then return end
          local root = vim.fs.root(bufnr, { ".git" })
          if root then on_dir(root) end
        end
      '';
      init_options = {
        editorInfo = {
          name = "Neovim";
          version.__raw = "tostring(vim.version())";
        };
        editorPluginInfo = {
          name = "Neovim";
          version.__raw = "tostring(vim.version())";
        };
      };
    };
  };

  extraConfigLua = # lua
    ''
      -- ── Состояние Copilot между сессиями ─────────────────────────────────
      -- Тумблер <leader>ui (см. keymaps ниже) включает/выключает Copilot целиком:
      --   • поднятие LSP-сервера copilot — через root_dir выше (выкл => сервер и
      --     vopono-обёртка из ai/launcher.nix вообще не стартуют, а не «стартуют
      --     и сразу убиваются»);
      --   • нативный inline-completion (ghost text).
      -- Состояние пишем в файл под stdpath("state") и восстанавливаем на старте,
      -- поэтому оно переживает рестарт nvim.
      local state_file = vim.fn.stdpath("state") .. "/copilot-enabled"

      local function copilot_read()
        local f = io.open(state_file, "r")
        if not f then return true end -- по умолчанию включён
        local s = f:read("*a")
        f:close()
        return vim.trim(s or "") ~= "0"
      end

      local function copilot_write(on)
        local f = io.open(state_file, "w")
        if f then
          f:write(on and "1" or "0")
          f:close()
        end
      end

      -- Флаг читаем СИНХРОННО в init — до первого FileType, чтобы root_dir увидел
      -- актуальное значение ещё до автостарта сервера (иначе сервер успел бы
      -- подняться до vim.schedule). pcall на inline — на случай nvim < 0.12.
      _G.copilot_enabled = copilot_read()
      pcall(function() vim.lsp.inline_completion.enable(_G.copilot_enabled) end)

      -- Глобальный тумблер (вешается на <leader>ui).
      function _G.copilot_toggle()
        _G.copilot_enabled = not _G.copilot_enabled
        copilot_write(_G.copilot_enabled)
        pcall(function() vim.lsp.inline_completion.enable(_G.copilot_enabled) end)
        if _G.copilot_enabled then
          -- заново подцепляем сервер к уже открытым буферам (root_dir теперь
          -- пропустит, т.к. флаг true)
          pcall(vim.lsp.enable, "copilot")
        else
          -- глушим живые клиенты (и их vopono-обёртку)
          for _, c in ipairs(vim.lsp.get_clients({ name = "copilot" })) do
            pcall(function() c:stop() end)
          end
        end
        vim.notify("Copilot " .. (_G.copilot_enabled and "enabled" or "disabled"))
      end

      -- copilot-language-server логинится через GitHub device-flow. Так как
      -- nixvim не везёт lsp/copilot.lua из nvim-lspconfig, команды
      -- :CopilotSignIn / :CopilotSignOut вешаем сами на LspAttach (повторяем
      -- логику lspconfig: LSP-методы 'signIn'/'signOut' + client:exec_cmd для
      -- завершения device-flow).
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_copilot_auth", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "copilot" then return end
          local buf = args.buf

          vim.api.nvim_buf_create_user_command(buf, "CopilotSignIn", function()
            client:request("signIn", vim.empty_dict(), function(err, result)
              if err or not result then
                vim.notify("Copilot signIn failed: " .. vim.inspect(err), vim.log.levels.ERROR)
                return
              end
              if result.status == "AlreadySignedIn" or result.status == "OK" then
                vim.notify("Copilot: already signed in" .. (result.user and (" as " .. result.user) or ""))
                return
              end
              local code = result.userCode
              local uri = result.verificationUri or "https://github.com/login/device"
              if code then
                pcall(vim.fn.setreg, "+", code)
                vim.notify("Copilot: device code " .. code .. " copied. Open " .. uri .. " and paste it.")
              end
              if result.command then
                client:exec_cmd(result.command, { bufnr = buf }, function(e, r)
                  if e then
                    vim.notify("Copilot sign-in error: " .. vim.inspect(e), vim.log.levels.ERROR)
                  elseif r then
                    vim.notify("Copilot: signed in" .. (r.user and (" as " .. r.user) or ""))
                  end
                end)
              end
            end, buf)
          end, { desc = "Copilot: sign in (GitHub device flow)" })

          vim.api.nvim_buf_create_user_command(buf, "CopilotSignOut", function()
            client:request("signOut", vim.empty_dict(), function()
              vim.notify("Copilot: signed out")
            end, buf)
          end, { desc = "Copilot: sign out" })
        end,
      })
    '';

  keymaps = [
    # Принять подсказку Copilot. Сначала нативный inline-completion под курсором
    # (ghost text); если его нет — sidekick NES (прыжок к «следующей правке» / её
    # применение, см. ai/sidekick.nix). В нормальном режиме inline не показывается,
    # поэтому там <C-l> = чисто NES. <Tab> остаётся за blink (qol/autocomplete.nix).
    {
      mode = [
        "i"
        "n"
      ];
      key = "<C-l>";
      action.__raw = ''
        function()
          if vim.lsp.inline_completion.get() then return end
          pcall(function() require("sidekick").nes_jump_or_apply() end)
        end
      '';
      options.desc = "Accept AI suggestion (Copilot inline / NES)";
    }
    # Циклим между кандидатами inline-подсказки (как в LazyVim copilot-native).
    {
      mode = "i";
      key = "<M-]>";
      action.__raw = "function() vim.lsp.inline_completion.select({ count = 1 }) end";
      options.desc = "Copilot: next suggestion";
    }
    {
      mode = "i";
      key = "<M-[>";
      action.__raw = "function() vim.lsp.inline_completion.select({ count = -1 }) end";
      options.desc = "Copilot: prev suggestion";
    }
    # Тумблер Copilot целиком (LSP + inline-движок). Состояние сохраняется между
    # сессиями (см. extraConfigLua). Приём подсказок — на <C-l> выше.
    {
      mode = "n";
      key = "<leader>ui";
      action.__raw = "function() _G.copilot_toggle() end";
      options.desc = "Toggle Copilot (LSP + inline, persisted)";
    }
  ];
}
