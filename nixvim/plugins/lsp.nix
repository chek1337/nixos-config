{ ... }:
{
  plugins.lsp.enable = true;
  plugins.lspkind.enable = true;

  extraConfigLua = ''
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN]  = "",
          [vim.diagnostic.severity.HINT]  = "",
          [vim.diagnostic.severity.INFO]  = "",
        },
      },
    })

    for _, lhs in ipairs({ "gra", "gri", "grn", "grr", "grt", "grx" }) do
      pcall(vim.keymap.del, "n", lhs)
      pcall(vim.keymap.del, "x", lhs)
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("clangd_switch_source_header", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "clangd" then
          vim.keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", {
            buffer = args.buf,
            desc = "Switch Source/Header (C/C++)",
          })
        end
      end,
    })
  '';
}
