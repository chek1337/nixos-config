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

      local function read_file(path)
        local f = io.open(path, "r")
        if not f then return nil end
        local content = f:read("*a")
        f:close()
        return content
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

      function M.set(folders, name)
        state.folders = folders
        state.name    = name
        publish()
        vim.api.nvim_exec_autocmds("User", { pattern = "WorkspaceChanged", modeline = false })
      end

      function M.clear()
        if #state.folders == 0 and state.name == nil then
          notify("workspace already empty")
          return
        end
        M.set({}, nil)
        notify("workspace cleared")
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

      function M.list()
        if #state.folders == 0 then
          notify("workspace is empty")
          return
        end
        local lines = { "Workspace: " .. (state.name or "<unnamed>") }
        for _, p in ipairs(state.folders) do lines[#lines + 1] = "  " .. p end
        notify(table.concat(lines, "\n"))
      end

      function M.edit(name)
        ensure_registry()
        if name and name ~= "" then
          vim.cmd.edit(REGISTRY .. "/" .. name .. ".code-workspace")
          return
        end

        local items = {}
        for _, fname in ipairs(registry_files()) do
          items[#items + 1] = {
            text = fname:gsub("%.code%-workspace$", ""),
            file = REGISTRY .. "/" .. fname,
          }
        end

        if #items == 0 then
          vim.ui.input({ prompt = "New workspace name: " }, function(n)
            if n and n ~= "" then
              vim.cmd.edit(REGISTRY .. "/" .. n .. ".code-workspace")
            end
          end)
          return
        end

        local snacks_ok, snacks = pcall(require, "snacks")
        if snacks_ok and snacks.picker then
          snacks.picker.pick({
            source  = "static",
            title   = "Edit Workspace",
            items   = items,
            format  = "text",
            preview = "file",
            confirm = function(picker, item)
              picker:close()
              vim.cmd.edit(item.file)
            end,
          })
        else
          local labels = {}
          for _, it in ipairs(items) do labels[#labels + 1] = it.text end
          vim.ui.select(labels, { prompt = "Edit workspace:" }, function(choice)
            if choice then
              vim.cmd.edit(REGISTRY .. "/" .. choice .. ".code-workspace")
            end
          end)
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

      vim.api.nvim_create_user_command("WorkspaceEdit", function(args)
        M.edit(args.args)
      end, { nargs = "?", complete = name_complete, desc = "Edit workspace JSON" })

      vim.api.nvim_create_user_command("WorkspaceList", function() M.list() end,
        { desc = "List workspace folders" })

      vim.api.nvim_create_user_command("WorkspaceClear", function() M.clear() end,
        { desc = "Clear workspace (fall back to cwd/root)" })
    '';

  vim.keymaps = [
    {
      key = "<leader>wl";
      mode = "n";
      action = "<cmd>WorkspaceLoad<cr>";
      desc = "Load workspace";
    }
    {
      key = "<leader>we";
      mode = "n";
      action = "<cmd>WorkspaceEdit<cr>";
      desc = "Edit workspace JSON";
    }
    {
      key = "<leader>wL";
      mode = "n";
      action = "<cmd>WorkspaceList<cr>";
      desc = "List folders";
    }
    {
      key = "<leader>wc";
      mode = "n";
      action = "<cmd>WorkspaceClear<cr>";
      desc = "Clear workspace";
    }
  ];
}
