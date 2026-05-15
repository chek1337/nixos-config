{ pkgs, ... }:
{
  vim.extraPackages = [ pkgs.texliveMedium ];

  vim.globals = {
    vimtex_view_method = "zathura";
    vimtex_compiler_method = "latexmk";
    vimtex_mappings_enabled = 0;
    vimtex_imaps_enabled = 0;
    vimtex_quickfix_mode = 0;
  };

  vim.extraPlugins = with pkgs.vimPlugins; {
    vimtex = {
      package = vimtex;
      setup = # lua
        ''
          vim.api.nvim_create_autocmd("FileType", {
            pattern = { "tex", "plaintex", "context" },
            callback = function(args)
              local o = { buffer = args.buf }
              local m = vim.tbl_extend
              vim.keymap.set("n", "<leader>ll", "<Plug>(vimtex-compile)",       m("force", o, { desc = "Compile" }))
              vim.keymap.set("n", "<leader>lv", "<Plug>(vimtex-view)",          m("force", o, { desc = "View PDF" }))
              vim.keymap.set("n", "<leader>lc", "<Plug>(vimtex-clean)",         m("force", o, { desc = "Clean" }))
              vim.keymap.set("n", "<leader>lk", "<Plug>(vimtex-stop)",          m("force", o, { desc = "Stop compiler" }))
              vim.keymap.set("n", "<leader>lt", "<Plug>(vimtex-toc-toggle)",    m("force", o, { desc = "TOC toggle" }))
              vim.keymap.set("n", "<leader>le", "<Plug>(vimtex-errors)",        m("force", o, { desc = "Errors" }))
              vim.keymap.set("n", "<leader>li", "<Plug>(vimtex-info)",          m("force", o, { desc = "Info" }))
            end,
          })
        '';
    };
  };
}
