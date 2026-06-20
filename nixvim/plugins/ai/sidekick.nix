{ pkgs, ... }:
{
  # sidekick.nvim (folke) — Next Edit Suggestion («Cursor-овский» NES: предлагает
  # следующую правку по контексту) + терминальные AI CLI прямо в редакторе.
  # NES работает поверх copilot-language-server (см. ai/copilot.nix) — nixvim сам
  # ассертит, что lsp.servers.copilot.enable включён, когда nes.enabled = true.
  # plugins.sidekick = {
  #   enable = true;
  #   settings = {
  #     nes.enabled = true;
  #   };
  # };
  #
  # # CLI sidekick (терминальные агенты) детектятся по PATH. Кладём claude-code,
  # # чтобы <leader>k* работали из коробки (chat по-крупному — это avante).
  # extraPackages = [ pkgs.claude-code ];
  #
  # keymaps =
  #   let
  #     cli = key: mode: fn: desc: {
  #       inherit key mode;
  #       action.__raw = ''function() require("sidekick.cli").${fn} end'';
  #       options = {
  #         inherit desc;
  #         silent = true;
  #       };
  #     };
  #   in
  #   [
  #     # NES (прыжок к «следующей правке» / её применение) висит на <C-l> вместе
  #     # с приёмом inline-подсказки — см. ai/copilot.nix. Здесь только тумблер.
  #     {
  #       mode = "n";
  #       key = "<leader>uN";
  #       action.__raw = ''function() require("sidekick.nes").toggle() end'';
  #       options.desc = "Toggle Sidekick NES";
  #     }
  #
  #     # Терминальные CLI на префиксе <leader>k (<leader>a занят avante).
  #     (cli "<leader>kk" "n" "toggle()" "Sidekick CLI: toggle")
  #     (cli "<leader>ks" "n" "select()" "Sidekick CLI: select tool")
  #     (cli "<leader>kd" "n" "close()" "Sidekick CLI: detach/close")
  #     (cli "<leader>kt" [ "n" "x" ] ''send({ msg = "{this}" })'' "Sidekick CLI: send this")
  #     (cli "<leader>kf" "n" ''send({ msg = "{file}" })'' "Sidekick CLI: send file")
  #     (cli "<leader>kv" "x" ''send({ msg = "{selection}" })'' "Sidekick CLI: send selection")
  #     (cli "<leader>kp" [ "n" "x" ] "prompt()" "Sidekick CLI: prompts")
  #     (cli "<c-.>" [ "n" "x" "i" "t" ] "focus()" "Sidekick CLI: focus")
  #   ];
}
