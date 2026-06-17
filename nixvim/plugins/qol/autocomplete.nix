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

      # Context-aware Tab (логика пресета "super-tab", собранная вручную поверх
      # "enter", чтобы <CR>/<C-y> остались accept'ом):
      #   • <Tab> вне сниппета — `select_and_accept`: сразу подставляет первое
      #     предложение (ghost_text показывает, что именно подставится).
      #   • <Tab> внутри активного сниппета — `cmp.accept()` принимает ТОЛЬКО
      #     явно выбранный (<C-n>/<C-p>) item; т.к. preselect = false, по
      #     умолчанию ничего не выбрано → проваливаемся в `snippet_forward` и
      #     прыгаем по плейсхолдерам. Так LSP-меню внутри сниппета не перехватывает
      #     прыжок, но принять подсказку всё равно можно, понавигировав вручную.
      #   • <S-Tab> — `snippet_backward`, иначе fallback.
      #   • <CR> / <C-y> — accept (из пресета "enter").
      #   • <C-n> / <C-p>, <Up>/<Down> — навигация по меню (из пресета).
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
        ghost_text.enabled = true;
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
