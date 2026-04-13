{ ... }:

{
  vim.autocomplete.blink-cmp = {
    enable = true;
    friendly-snippets.enable = true;

    setupOpts = {
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
        list = {
          selection = {
            preselect = false;
          };
        };

        ghost_text = {
          enabled = true;
        };
      };

      sources = {
        default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
      };

      fuzzy = {
        implementation = "prefer_rust_with_warning";
      };
    };
  };
}
