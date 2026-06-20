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
      "AvanteAsk"
      "AvanteChat"
      "AvanteChatNew"
      "AvanteEdit"
      "AvanteFocus"
      "AvanteHistory"
      "AvanteModels"
      "AvanteRefresh"
      "AvanteStop"
      "AvanteSwitchProvider"
      "AvanteToggle"
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
      };

      # Кейбинды вешаем сами (ниже), как в LazyVim-extra.
      behaviour.auto_set_keymaps = false;
      selection.hint_display = "none";
    };
  };

  keymaps =
    let
      mk = key: cmd: desc: {
        inherit key;
        mode = "n";
        action = "<cmd>${cmd}<CR>";
        options = {
          inherit desc;
          silent = true;
        };
      };
    in
    [
      (mk "<leader>aa" "AvanteAsk" "Ask Avante")
      (mk "<leader>ac" "AvanteChat" "Chat with Avante")
      (mk "<leader>ae" "AvanteEdit" "Edit Avante")
      (mk "<leader>af" "AvanteFocus" "Focus Avante")
      (mk "<leader>ah" "AvanteHistory" "Avante History")
      (mk "<leader>am" "AvanteModels" "Select Avante Model")
      (mk "<leader>an" "AvanteChatNew" "New Avante Chat")
      (mk "<leader>ap" "AvanteSwitchProvider" "Switch Avante Provider")
      (mk "<leader>ar" "AvanteRefresh" "Refresh Avante")
      (mk "<leader>as" "AvanteStop" "Stop Avante")
      (mk "<leader>at" "AvanteToggle" "Toggle Avante")
    ];
}
