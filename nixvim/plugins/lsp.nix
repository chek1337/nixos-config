{ ... }:
{
  plugins.lsp.enable = true;
  plugins.lspkind.enable = true;

  extraConfigLua = ''
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN]  = "",
          [vim.diagnostic.severity.HINT]  = "",
          [vim.diagnostic.severity.INFO]  = "",
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

  keymaps = [
    {
      key = "gh";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.hover()<cr>";
      options.desc = "LSP Hover";
    }
    {
      key = "<leader>ca";
      mode = [
        "n"
        "x"
      ];
      action.__raw = "function() vim.lsp.buf.code_action() end";
      options.desc = "Code Action";
    }
    {
      key = "<leader>cr";
      mode = "n";
      action.__raw = "function() vim.lsp.buf.rename() end";
      options.desc = "Rename";
    }
    {
      key = "<leader>cc";
      mode = [
        "n"
        "x"
      ];
      action.__raw = "function() vim.lsp.codelens.run() end";
      options.desc = "Run Codelens";
    }
    {
      key = "<leader>cC";
      mode = "n";
      action.__raw = "function() vim.lsp.codelens.refresh() end";
      options.desc = "Refresh & Display Codelens";
    }

    # Diagnostic virtual lines
    {
      key = "<leader>udd";
      mode = "n";
      action.__raw = # lua
        ''
          function()
            local cfg = vim.diagnostic.config()
            local virt = cfg.virtual_lines

            if type(virt) == "table" and virt.current_line then
              vim.diagnostic.config({ virtual_lines = false })
            else
              vim.diagnostic.config({ virtual_lines = { current_line = true } })
            end
          end
        '';
      options.desc = "Toggle virtual lines for current line only";
    }
    {
      key = "<leader>udD";
      mode = "n";
      action.__raw = # lua
        ''
          function()
            local cfg = vim.diagnostic.config()
            local virt = cfg.virtual_lines

            if virt == true or (type(virt) == "table" and not virt.current_line) then
              vim.diagnostic.config({ virtual_lines = false })
            else
              vim.diagnostic.config({ virtual_lines = true })
            end
          end
        '';
      options.desc = "Toggle full virtual lines";
    }
  ];
}
