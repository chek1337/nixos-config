{ ... }:
{
  vim.luaConfigRC.workspace-module = # lua
    ''
      local M = {}
      local uv = vim.uv or vim.loop
      local REGISTRY = vim.fn.expand("~/.config/nvim-workspaces")

      local state = {
        folders = {},
        name    = nil,
      }

      local function publish()
        vim.g.workspace_folders = state.folders
        vim.g.workspace_name    = state.name
      end
      publish()

      local function notify(msg, level)
        vim.notify("[workspace] " .. msg, level or vim.log.levels.INFO)
      end

      local function abs(p)
        return vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(p), ":p"))
      end

      local function clone(list)
        local r = {}
        for i, v in ipairs(list) do r[i] = v end
        return r
      end

      local function ensure_registry()
        if vim.fn.isdirectory(REGISTRY) == 0 then
          vim.fn.mkdir(REGISTRY, "p")
        end
      end

      local function as_lsp_folder(path)
        return {
          uri  = vim.uri_from_fname(path),
          name = vim.fn.fnamemodify(path, ":t"),
        }
      end

      local function lsp_folders(list)
        local out = {}
        for _, p in ipairs(list) do out[#out + 1] = as_lsp_folder(p) end
        return out
      end

      local function read_file(path)
        local f = io.open(path, "r")
        if not f then return nil end
        local content = f:read("*a")
        f:close()
        return content
      end

      local function write_atomic(path, content)
        local tmp = path .. ".tmp"
        local f, ferr = io.open(tmp, "w")
        if not f then return false, ferr end
        f:write(content)
        f:close()
        local ok, err = uv.fs_rename(tmp, path)
        if not ok then return false, err end
        return true
      end

      local function registry_files()
        ensure_registry()
        local out = {}
        for _, name in ipairs(vim.fn.readdir(REGISTRY)) do
          if name:match("%.code%-workspace$") then out[#out + 1] = name end
        end
        return out
      end

      function M.parse_workspace_file(path)
        local raw = read_file(path)
        if not raw then
          notify("cannot read " .. path, vim.log.levels.ERROR)
          return {}
        end
        local ok, data = pcall(vim.json.decode, raw)
        if not ok or type(data) ~= "table" or type(data.folders) ~= "table" then
          notify("invalid JSON in " .. path, vim.log.levels.ERROR)
          return {}
        end
        local dir = vim.fs.dirname(path)
        local result = {}
        for _, entry in ipairs(data.folders) do
          if type(entry) == "table" and type(entry.path) == "string" then
            local p = entry.path
            if not vim.startswith(p, "/") and not p:match("^~") then
              p = vim.fs.joinpath(dir, p)
            end
            p = abs(p)
            local stat = uv.fs_stat(p)
            if stat and stat.type == "directory" then
              result[#result + 1] = p
            else
              notify("skipping missing folder: " .. p, vim.log.levels.WARN)
            end
          end
        end
        return result
      end

      function M.current() return clone(state.folders) end
      function M.name()    return state.name end

      function M.diff_and_notify(old, new)
        local old_set, new_set = {}, {}
        for _, p in ipairs(old) do old_set[p] = true end
        for _, p in ipairs(new) do new_set[p] = true end
        local added, removed = {}, {}
        for _, p in ipairs(new) do if not old_set[p] then added[#added + 1] = p end end
        for _, p in ipairs(old) do if not new_set[p] then removed[#removed + 1] = p end end
        if #added == 0 and #removed == 0 then return end

        for _, client in ipairs(vim.lsp.get_clients()) do
          local ws = client.server_capabilities and client.server_capabilities.workspace
          local cap = ws and ws.workspaceFolders or nil
          if cap and cap.supported then
            if cap.changeNotifications then
              client:notify("workspace/didChangeWorkspaceFolders", {
                event = {
                  added   = lsp_folders(added),
                  removed = lsp_folders(removed),
                },
              })
            else
              notify(
                client.name .. ": no changeNotifications, run :LspRestart",
                vim.log.levels.WARN
              )
            end
          end
        end
      end

      function M.set(folders, name)
        local old = clone(state.folders)
        state.folders = folders
        state.name    = name
        publish()
        M.diff_and_notify(old, folders)
        vim.api.nvim_exec_autocmds("User", { pattern = "WorkspaceChanged", modeline = false })
      end

      function M.load(name)
        local path = REGISTRY .. "/" .. name .. ".code-workspace"
        if vim.fn.filereadable(path) == 0 then
          notify("not found: " .. path, vim.log.levels.ERROR)
          return
        end
        local folders = M.parse_workspace_file(path)
        M.set(folders, name)
        notify(("loaded %s (%d folders)"):format(name, #folders))
      end

      function M.add(path)
        if not path or path == "" then return end
        local p = abs(path)
        local stat = uv.fs_stat(p)
        if not stat or stat.type ~= "directory" then
          notify("not a directory: " .. p, vim.log.levels.ERROR)
          return
        end
        for _, x in ipairs(state.folders) do
          if x == p then
            notify("already present: " .. p, vim.log.levels.WARN)
            return
          end
        end
        local nxt = clone(state.folders)
        nxt[#nxt + 1] = p
        M.set(nxt, state.name)
        notify("added: " .. p)
      end

      function M.remove(path)
        if not path or path == "" then return end
        local p = abs(path)
        local nxt, removed = {}, false
        for _, x in ipairs(state.folders) do
          if x == p then removed = true else nxt[#nxt + 1] = x end
        end
        if not removed then
          notify("not in workspace: " .. p, vim.log.levels.WARN)
          return
        end
        M.set(nxt, state.name)
        notify("removed: " .. p)
      end

      function M.save(name)
        if not name or name == "" then
          notify("save: name required", vim.log.levels.ERROR)
          return
        end
        ensure_registry()
        local folders = {}
        for _, p in ipairs(state.folders) do folders[#folders + 1] = { path = p } end
        local content = vim.json.encode({ folders = folders })
        local path = REGISTRY .. "/" .. name .. ".code-workspace"
        local ok, err = write_atomic(path, content)
        if ok then
          state.name = name
          publish()
          notify("saved: " .. path)
        else
          notify("save failed: " .. (err or "?"), vim.log.levels.ERROR)
        end
      end

      function M.list()
        if #state.folders == 0 then
          notify("workspace is empty")
          return
        end
        local lines = { "Workspace: " .. (state.name or "<unnamed>") }
        for _, p in ipairs(state.folders) do lines[#lines + 1] = "  " .. p end
        notify(table.concat(lines, "\n"))
      end

      function M.before_init(params, _config)
        if state.folders and #state.folders > 0 then
          params.workspaceFolders = lsp_folders(state.folders)
        end
      end

      function M.pick()
        local items = {}
        for _, fname in ipairs(registry_files()) do
          items[#items + 1] = {
            text = fname:gsub("%.code%-workspace$", ""),
            file = REGISTRY .. "/" .. fname,
          }
        end
        if #items == 0 then
          notify("no workspaces in " .. REGISTRY)
          return
        end

        local snacks_ok, snacks = pcall(require, "snacks")
        if snacks_ok and snacks.picker then
          snacks.picker.pick({
            source  = "static",
            title   = "Workspaces",
            items   = items,
            format  = "text",
            preview = "file",
            confirm = function(picker, item)
              picker:close()
              M.load(item.text)
            end,
          })
        else
          local labels = {}
          for _, it in ipairs(items) do labels[#labels + 1] = it.text end
          vim.ui.select(labels, { prompt = "Workspace:" }, function(choice)
            if choice then M.load(choice) end
          end)
        end
      end

      package.loaded["chek.workspace"] = M

      -- User commands -----------------------------------------------------

      local function name_complete()
        local r = {}
        for _, f in ipairs(registry_files()) do
          r[#r + 1] = f:gsub("%.code%-workspace$", "")
        end
        return r
      end

      vim.api.nvim_create_user_command("WorkspaceLoad", function(args)
        if args.args and args.args ~= "" then
          M.load(args.args)
        else
          M.pick()
        end
      end, { nargs = "?", complete = name_complete, desc = "Load multi-root workspace" })

      vim.api.nvim_create_user_command("WorkspaceAdd", function(args)
        if args.args and args.args ~= "" then
          M.add(args.args)
        else
          vim.ui.input({ prompt = "Add folder: ", completion = "dir" }, function(p)
            if p and p ~= "" then M.add(p) end
          end)
        end
      end, { nargs = "?", complete = "dir", desc = "Add folder to workspace" })

      vim.api.nvim_create_user_command("WorkspaceRemove", function(args)
        if args.args and args.args ~= "" then
          M.remove(args.args)
        elseif #state.folders == 0 then
          notify("workspace is empty")
        else
          vim.ui.select(M.current(), { prompt = "Remove folder:" }, function(c)
            if c then M.remove(c) end
          end)
        end
      end, {
        nargs = "?",
        complete = function() return M.current() end,
        desc = "Remove folder from workspace",
      })

      vim.api.nvim_create_user_command("WorkspaceSave", function(args)
        if args.args and args.args ~= "" then
          M.save(args.args)
        else
          vim.ui.input({ prompt = "Save as: " }, function(n)
            if n and n ~= "" then M.save(n) end
          end)
        end
      end, { nargs = "?", desc = "Save workspace to registry" })

      vim.api.nvim_create_user_command("WorkspaceList", function() M.list() end,
        { desc = "List workspace folders" })
    '';

  vim.keymaps = [
    {
      key = "<leader>wl";
      mode = "n";
      action = "<cmd>WorkspaceLoad<cr>";
      desc = "Load workspace";
    }
    {
      key = "<leader>wa";
      mode = "n";
      action = "<cmd>WorkspaceAdd<cr>";
      desc = "Add folder";
    }
    {
      key = "<leader>wr";
      mode = "n";
      action = "<cmd>WorkspaceRemove<cr>";
      desc = "Remove folder";
    }
    {
      key = "<leader>ws";
      mode = "n";
      action = "<cmd>WorkspaceSave<cr>";
      desc = "Save workspace";
    }
    {
      key = "<leader>wL";
      mode = "n";
      action = "<cmd>WorkspaceList<cr>";
      desc = "List folders";
    }
  ];
}
