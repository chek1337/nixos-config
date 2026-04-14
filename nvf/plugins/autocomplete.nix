{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
in

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

      cmdline = {
        sources = [ "cmdline" ];
        keymap = {
          preset = "cmdline";
          "<Right>" = [ ];
          "<Left>" = [ ];
        };
        completion = {
          list.selection.preselect = false;
          menu.auto_show = mkLuaInline ''
            function(ctx)
              return vim.fn.getcmdtype() == ":"
            end
          '';
          ghost_text.enabled = true;
        };
      };

      fuzzy = {
        implementation = "prefer_rust_with_warning";
      };
    };
  };
}
