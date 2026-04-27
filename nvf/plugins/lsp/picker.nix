{ ... }:
{
  vim.luaConfigRC.lsp-picker = # lua
    ''
      _G.lsp_primary = { python = "ty" }

      _G.lsp_servers_for_ft = function(ft)
        local seen = {}
        local function add(name, filetypes)
          if not name or seen[name] or type(filetypes) ~= "table" then return end
          for _, f in ipairs(filetypes) do
            if f == ft then seen[name] = true; return end
          end
        end

        if type(vim.lsp.config) == "table" then
          local internal = rawget(vim.lsp.config, "_configs")
          if type(internal) == "table" then
            for name, cfg in pairs(internal) do
              if name ~= "*" and type(cfg) == "table" then add(name, cfg.filetypes) end
            end
          end
        end

        local ok, configs = pcall(require, "lspconfig.configs")
        if ok and type(configs) == "table" then
          for name, cfg in pairs(configs) do
            local fts = (cfg and cfg.filetypes)
              or (cfg and cfg.config_def and cfg.config_def.default_config and cfg.config_def.default_config.filetypes)
            add(name, fts)
          end
        end

        for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          seen[c.name] = true
        end

        local list = {}
        for name in pairs(seen) do table.insert(list, name) end
        table.sort(list)
        return list
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local c = vim.lsp.get_client_by_id(args.data.client_id)
          if not c then return end
          local ft = vim.bo[args.buf].filetype
          local pref = _G.lsp_primary[ft]
          if not pref or c.name == pref then return end
          for _, s in ipairs(_G.lsp_servers_for_ft(ft)) do
            if s == c.name then
              vim.schedule(function() vim.lsp.stop_client(c.id, true) end)
              return
            end
          end
        end,
      })

      _G.lsp_pick = function()
        local ft = vim.bo.filetype
        local servers = _G.lsp_servers_for_ft(ft)
        if #servers == 0 then
          vim.notify("no LSP for filetype=" .. ft, vim.log.levels.WARN)
          return
        end
        local function apply(choice)
          _G.lsp_primary[ft] = choice
          for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
            if c.name ~= choice then
              for _, s in ipairs(servers) do
                if c.name == s then
                  vim.lsp.stop_client(c.id, true)
                  break
                end
              end
            end
          end
          vim.cmd("LspStart " .. choice)
          vim.notify("LSP active for " .. ft .. ": " .. choice)
        end
        if #servers == 1 then apply(servers[1]); return end
        vim.ui.select(servers, { prompt = "Pick LSP for " .. ft }, function(choice)
          if choice then apply(choice) end
        end)
      end
    '';

  vim.keymaps = [
    {
      key = "<leader>cl";
      mode = "n";
      lua = true;
      action = "function() _G.lsp_pick() end";
      desc = "LSP: pick server";
    }
  ];
}
