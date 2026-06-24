{
  pkgs,
  ...
}:
let
  acpAgent = "${pkgs.claude-agent-acp}/bin/claude-agent-acp";
in
{
  # avante.nvim — «Cursor внутри Neovim»: чат с контекстом репозитория и
  # применение правок через diff-панель. Конфиг навеян LazyVim-extra
  # (lua/lazyvim/plugins/extras/ai/avante.lua), но провайдер — Claude Code
  # через ACP, чтобы переиспользовать подписку, а не платный Anthropic API.
  #
  # ACP-агент берём декларативно из nixpkgs (claude-agent-acp, Claude Agent
  # SDK), а не через `npx -y -g @zed-industries/claude-code-acp`, чтобы не
  # тянуть пакет из npm в рантайме. Авторизация — общий логин Claude Code
  # (~/.claude). Объявляем СВОЙ ключ acp_providers, а не правим дефолтный
  # `claude-code`: avante мёржит конфиг через tbl_deep_extend("force"), и
  # переопределение списка args дефолтного блока сработало бы некорректно.
  plugins.avante = {
    enable = true;

    lazyLoad.settings.cmd = [
      "AvanteACPModels"
      "AvanteACPModes"
      "AvanteAsk"
      "AvanteChat"
      "AvanteChatNew"
      "AvanteClear"
      "AvanteEdit"
      "AvanteFocus"
      "AvanteHistory"
      "AvanteModels"
      "AvanteRefresh"
      "AvanteShowRepoMap"
      "AvanteStop"
      "AvanteSwitchProvider"
      "AvanteToggle"
    ];

    # Zen / full-view: чат на весь экран без сплита с кодом + лого
    # (api.zen_mode == full_view_ask). Команды для него нет, только Lua-функция,
    # поэтому биндим ЧЕРЕЗ lazyLoad.keys: lz.n сделает packadd перед вызовом —
    # из остальных keymaps `require("avante.api")` на холодную упал бы.
    lazyLoad.settings.keys = [
      {
        __unkeyed-1 = "<leader>az";
        __unkeyed-2.__raw = "function() require('avante.api').zen_mode() end";
        mode = "n";
        desc = "Avante Zen (full view)";
      }
    ];

    settings = {
      provider = "claude-code-nix";

      # command/args считаем В РАНТАЙМЕ через ai_launcher (ai/launcher.nix):
      # на хостах агент завернётся в vopono, в standalone/на чужой машине —
      # прямой запуск или свой туннель ($NVIM_AI_WRAPPER / ~/.config/nvim-ai/wrapper).
      acp_providers."claude-code-nix" = {
        command.__raw = ''require("ai_launcher").command({ "${acpAgent}" })'';
        args.__raw = ''require("ai_launcher").args({ "${acpAgent}" })'';
        env.NODE_NO_WARNINGS = "1";
        # HOME прокидываем ЯВНО: avante (libs/acp_client.lua) собирает окружение
        # дочернего процесса с нуля — только PATH + этот env, окружение nvim НЕ
        # наследуется. Без HOME обёртка-vopono (~/.config/nvim-ai/wrapper) считает
        # `--custom $HOME/.config/vopono/wg.conf` с пустым HOME → конфиг не найден,
        # vopono падает, агент не стартует. А внутри namespace агенту HOME нужен,
        # чтобы найти ~/.claude. copilot (vim.lsp) наследует env и потому работает.
        env.HOME.__raw = ''vim.fn.expand("$HOME")'';
      };

      # Кейбинды вешаем сами (ниже), как в LazyVim-extra.
      behaviour.auto_set_keymaps = false;

      # Дефолт avante — auto_approve_tool_permissions=true: агент молча применяет
      # ВСЕ правки/тулколлы без спроса. Выключаем, чтобы каждую правку
      # подтверждать вручную: всплывёт confirm с [Y]es / [A]ll yes / [N]o
      # (клавиши y/a/n, навигация Tab/←→/h l, выбор <CR>). Отклонение для ACP
      # идёт без поля «причина» (skip_reject_prompt), поэтому «комментарий» =
      # нажать n и дописать в инпут, что переделать.
      behaviour.auto_approve_tool_permissions = false;
      # Стиль подтверждения: "popup" — модалка с понятными y/a/n
      # (альтернатива — дефолтный "inline_buttons", кнопки прямо в чате).
      behaviour.confirmation_ui_style = "popup";

      selection.hint_display = "none";
    };
  };

  keymaps =
    let
      mk = modes: key: cmd: desc: {
        inherit key;
        mode = modes;
        action = "<cmd>${cmd}<CR>";
        options = {
          inherit desc;
          silent = true;
        };
      };
      n = mk [ "n" ];
      # Visual-режим тоже: <cmd>…<CR> НЕ выходит из visual, а AvanteAsk/AvanteEdit
      # сами читают выделение через getpos("v") (utils.get_visual_selection_and_range),
      # поэтому из `x` спрашиваем/правим прямо по выделенному коду.
      nx = mk [
        "n"
        "x"
      ];
    in
    [
      (nx "<leader>aa" "AvanteAsk" "Ask Avante (selection)")
      (n "<leader>ab" "AvanteShowRepoMap" "Avante Repo Map")
      (n "<leader>ac" "AvanteChat" "Chat with Avante")
      (n "<leader>ax" "AvanteClear" "Clear Avante Chat")
      (nx "<leader>ae" "AvanteEdit" "Edit Avante (selection)")
      (n "<leader>af" "AvanteFocus" "Focus Avante")
      (n "<leader>ah" "AvanteHistory" "Avante History")
      # ACP-провайдер (claude-code-nix): модель/режим берём у агента, а не из
      # Config.providers — поэтому ACP-селекторы, а не AvanteModels (сначала
      # нужен открытый сайдбар с активной сессией).
      (n "<leader>am" "AvanteACPModels" "Select Claude Model")
      (n "<leader>aM" "AvanteACPModes" "Select Agent Mode")
      (n "<leader>an" "AvanteChatNew" "New Avante Chat")
      (n "<leader>ap" "AvanteSwitchProvider" "Switch Avante Provider")
      (n "<leader>ar" "AvanteRefresh" "Refresh Avante")
      (n "<leader>as" "AvanteStop" "Stop Avante")
      (n "<leader>at" "AvanteToggle" "Toggle Avante")
    ];
}
