{ ... }:
{
  plugins.blink-cmp = {
    enable = true;

    # Eager: nixvim инжектит `require("blink-cmp").get_lsp_capabilities(...)`
    # в LSP-конфиг (`setupLspCapabilities`, по умолчанию ON), и это вызывается
    # на startup'е до любых InsertEnter-триггеров. Лень здесь несовместима с
    # корректными LSP capabilities — оставляем плагин в pack/start/.

    settings = {
      enabled.__raw = ''
        function() return vim.g.blink_cmp_enabled ~= false end
      '';

      # Context-aware <Tab> — целиком за blink (никаких copilot/NES здесь):
      #   • <Tab> вне сниппета → `select_and_accept`: подставляет выбранный
      #     (<C-n>/<C-p>) или первый пункт меню автодополнения.
      #   • <Tab> в активном сниппете → `cmp.accept()` принимает ТОЛЬКО явно
      #     выбранный item; preselect = false → по умолчанию выбора нет →
      #     проваливаемся в `snippet_forward` и прыгаем по плейсхолдерам.
      #   • <S-Tab> — `snippet_backward`, иначе fallback.
      #   • <CR> / <C-y> — accept (из пресета "enter").
      #   • <C-n> / <C-p>, <Up>/<Down> — навигация по меню (из пресета).
      # Приём inline-подсказки Copilot вынесен на <C-l> (см. ai/copilot.nix),
      # чтобы <Tab> остался полностью за blink.
      keymap = {
        preset = "enter";

        "<Tab>" = [
          {
            __raw = ''
              function(cmp)
                if cmp.snippet_active() then return cmp.accept() end
                return cmp.select_and_accept()
              end
            '';
          }
          "snippet_forward"
          "fallback"
        ];
        "<S-Tab>" = [
          "snippet_backward"
          "fallback"
        ];

        "<C-d>" = [
          "show"
          "show_documentation"
          "hide_documentation"
        ];
        "<C-e>" = [
          "hide"
          "fallback"
        ];
      };

      completion = {
        list.selection.preselect = false;
        # ghost_text выключен: его роль играет нативный copilot inline-completion
        # (ai/copilot.nix). Два ghost text'а на одной позиции конфликтуют визуально.
        ghost_text.enabled = false;
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 1500;
        };
      };

      sources.default = [
        "lsp"
        "path"
        "snippets"
        "buffer"
      ];

      cmdline = {
        sources = [ "cmdline" ];
        # В cmdline сниппетов нет — Tab безопасно принимает первое предложение
        # (vim-стиль), <CR> исполняет команду как обычно (без accept в пресете
        # cmdline для preset = "enter": Enter всегда executes, не accept).
        keymap = {
          preset = "enter";
          "<Tab>" = [
            "select_and_accept"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
            "fallback"
          ];
          "<C-Space>" = [
            "show"
            "show_documentation"
            "hide_documentation"
          ];
          "<C-e>" = [
            "hide"
            "fallback"
          ];
        };
        completion = {
          list.selection.preselect = false;
          menu.auto_show.__raw = ''
            function(ctx)
              return vim.fn.getcmdtype() == ":"
            end
          '';
          ghost_text.enabled = true;
        };
      };

      fuzzy.implementation = "prefer_rust_with_warning";
    };

    # Snacks toggle для <leader>uB. Раньше висел на autocmd `User VeryLazy`,
    # который в lz.n никогда не emit'ится → keymap не регистрировался. luaConfig.post
    # выполняется сразу после blink-cmp setup на startup.
    luaConfig.post = # lua
      ''
        Snacks.toggle({
          name = "blink.cmp",
          get = function()
            return vim.g.blink_cmp_enabled ~= false
          end,
          set = function(state)
            vim.g.blink_cmp_enabled = state
          end,
        }):map("<leader>uB")
      '';
  };
}
