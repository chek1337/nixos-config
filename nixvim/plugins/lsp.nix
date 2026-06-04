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
      group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        local buf = args.buf

        local function map(modes, lhs, rhs, desc, method)
          if method and not client:supports_method(method, { bufnr = buf }) then return end
          vim.keymap.set(modes, lhs, rhs, { buffer = buf, desc = desc })
        end

        -- Pure vim.lsp (одиночные прыжки / hover / sig)
        map("n", "gh", vim.lsp.buf.hover,          "LSP Hover",        "textDocument/hover")
        map("n", "gD", vim.lsp.buf.declaration,    "Goto Declaration", "textDocument/declaration")
        map("n", "gK", vim.lsp.buf.signature_help, "Signature Help",   "textDocument/signatureHelp")

        -- Snacks pickers (списком, не прыжком)
        map("n", "gd", function() require('snacks').picker.lsp_definitions() end,      "Goto Definition",      "textDocument/definition")
        map("n", "gr", function() require('snacks').picker.lsp_references() end,       "References",           "textDocument/references")
        map("n", "gI", function() require('snacks').picker.lsp_implementations() end,  "Goto Implementation",  "textDocument/implementation")
        map("n", "gy", function() require('snacks').picker.lsp_type_definitions() end, "Goto Type Definition", "textDocument/typeDefinition")

        map("n", "<leader>ss", function() require('snacks').picker.lsp_symbols() end,           "LSP Symbols",           "textDocument/documentSymbol")
        map("n", "<leader>sS", function() require('snacks').picker.lsp_workspace_symbols() end, "LSP Workspace Symbols", "workspace/symbol")

        map("n", "gai", function() require('snacks').picker.lsp_incoming_calls() end, "Calls Incoming", "textDocument/prepareCallHierarchy")
        map("n", "gao", function() require('snacks').picker.lsp_outgoing_calls() end, "Calls Outgoing", "textDocument/prepareCallHierarchy")

        map("n", "<a-n>", function() require('snacks').words.jump(vim.v.count1, true) end,  "Next Reference", "textDocument/documentHighlight")
        map("n", "<a-p>", function() require('snacks').words.jump(-vim.v.count1, true) end, "Prev Reference", "textDocument/documentHighlight")

        -- Code action / rename / codelens
        map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action,  "Code Action",                "textDocument/codeAction")
        map("n",          "<leader>cr", vim.lsp.buf.rename,       "Rename",                     "textDocument/rename")
        map({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run,     "Run Codelens",               "textDocument/codeLens")
        map("n",          "<leader>cC", vim.lsp.codelens.refresh, "Refresh & Display Codelens", "textDocument/codeLens")

        -- Snacks rename file — нужен любой из workspace file-rename методов
        if client:supports_method("workspace/willRenameFiles", { bufnr = buf })
          or client:supports_method("workspace/didRenameFiles", { bufnr = buf }) then
          vim.keymap.set("n", "<leader>cR", function() require('snacks').rename.rename_file() end,
            { buffer = buf, desc = "Rename File" })
        end

        if client.name == "clangd" then
          map("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", "Switch Source/Header (C/C++)")
        end
      end,
    })
  '';

  keymaps = [
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
