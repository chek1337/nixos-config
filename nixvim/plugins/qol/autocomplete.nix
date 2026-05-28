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

      keymap = {
        preset = "enter";

        "<Tab>" = [
          "select_and_accept"
          "snippet_forward"
          "fallback"
        ];
        "<S-Tab>" = [
          "select_prev"
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
        keymap = {
          preset = "enter";
          "<Tab>" = [
            "select_and_accept"
            "snippet_forward"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
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
