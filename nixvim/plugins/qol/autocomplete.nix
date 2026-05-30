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

      # Разделение ролей, чтобы Tab не конфликтовал со сниппетами:
      #   • <CR> / <C-y>  — accept выбранного item'а (из пресета "enter")
      #   • <Tab> / <S-Tab> — навигация по плейсхолдерам сниппета (из пресета)
      #   • <C-n> / <C-p>, <Up>/<Down> — навигация по меню (из пресета)
      # `select_and_accept` на Tab принципиально не вешаем: он всегда выбирает
      # первый item при открытом меню, даже без явной навигации, и ломает прыжок
      # по сниппету, когда LSP показывает подсказки внутри активного сниппета.
      keymap = {
        preset = "enter";

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
