local M = {
  active = false,
  folders = {},
  file_path = nil,
}

local WS_FILENAME = ".nvim-workspace.json"

local function resolve_path(base_dir, path)
  if vim.startswith(path, "/") then
    return vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
  end
  return vim.fn.fnamemodify(base_dir .. "/" .. path, ":p"):gsub("/$", "")
end

function M.load()
  local ws_file = vim.fn.getcwd() .. "/" .. WS_FILENAME
  if vim.fn.filereadable(ws_file) ~= 1 then
    M.active = false
    M.folders = {}
    M.file_path = nil
    return false
  end

  local content = vim.fn.readfile(ws_file)
  local ok, data = pcall(vim.json.decode, table.concat(content, "\n"))
  if not ok or type(data) ~= "table" or not data.folders then
    vim.notify("Invalid workspace file: " .. ws_file, vim.log.levels.ERROR)
    return false
  end

  local ws_dir = vim.fn.fnamemodify(ws_file, ":h")
  M.folders = {}
  for _, entry in ipairs(data.folders) do
    local p = resolve_path(ws_dir, entry.path)
    if vim.fn.isdirectory(p) == 1 then
      table.insert(M.folders, p)
    end
  end

  M.file_path = ws_file
  M.active = #M.folders > 0

  if M.active then
    vim.notify("Workspace loaded: " .. #M.folders .. " folder(s)", vim.log.levels.INFO)
  end
  return M.active
end

function M.reload()
  M.load()
end

function M.dirs()
  if M.active and #M.folders > 0 then
    return M.folders
  end
  return nil
end

function M.status()
  if M.active then
    return "W[" .. #M.folders .. "]"
  end
  return ""
end

local function read_json()
  if not M.file_path or vim.fn.filereadable(M.file_path) ~= 1 then
    return nil
  end
  local content = vim.fn.readfile(M.file_path)
  local ok, data = pcall(vim.json.decode, table.concat(content, "\n"))
  if ok and type(data) == "table" and data.folders then
    return data
  end
  return nil
end

local function write_json(data)
  local path = M.file_path or (vim.fn.getcwd() .. "/" .. WS_FILENAME)
  local json = vim.json.encode(data)
  -- Pretty-print the JSON
  local formatted = vim.fn.system({ "python3", "-m", "json.tool" }, json)
  if vim.v.shell_error == 0 then
    vim.fn.writefile(vim.split(formatted, "\n"), path)
  else
    vim.fn.writefile({ json }, path)
  end
end

function M.edit()
  local path = M.file_path or (vim.fn.getcwd() .. "/" .. WS_FILENAME)
  if vim.fn.filereadable(path) ~= 1 then
    local template = {
      folders = {
        { path = "." },
      },
    }
    write_json(template)
    M.file_path = path
  end
  vim.cmd.edit(path)
end

function M.add(path)
  path = path or vim.fn.getcwd()
  local data = read_json() or { folders = {} }
  table.insert(data.folders, { path = path })
  write_json(data)
  M.load()
end

function M.remove(path)
  if not path then
    vim.notify("Specify a path to remove", vim.log.levels.WARN)
    return
  end
  local data = read_json()
  if not data then
    return
  end
  local ws_dir = vim.fn.fnamemodify(M.file_path, ":h")
  local target = resolve_path(ws_dir, path)
  data.folders = vim.tbl_filter(function(entry)
    return resolve_path(ws_dir, entry.path) ~= target
  end, data.folders)
  write_json(data)
  M.load()
end

function M.info()
  if not M.active then
    vim.notify("No active workspace", vim.log.levels.INFO)
    return
  end
  local lines = { "Workspace: " .. M.file_path, "Folders:" }
  for _, f in ipairs(M.folders) do
    table.insert(lines, "  " .. f)
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

local function pick_folder_yazi()
  if not M.active or #M.folders == 0 then
    vim.notify("No active workspace", vim.log.levels.WARN)
    return
  end
  if #M.folders == 1 then
    require("yazi").yazi(nil, M.folders[1])
    return
  end
  vim.ui.select(M.folders, { prompt = "Workspace folder:" }, function(choice)
    if choice then
      require("yazi").yazi(nil, choice)
    end
  end)
end

local function setup_commands()
  vim.api.nvim_create_user_command("WorkspaceEdit", function()
    M.edit()
  end, {})
  vim.api.nvim_create_user_command("WorkspaceReload", function()
    M.reload()
  end, {})
  vim.api.nvim_create_user_command("WorkspaceAdd", function(opts)
    M.add(opts.args ~= "" and opts.args or nil)
  end, { nargs = "?" })
  vim.api.nvim_create_user_command("WorkspaceRemove", function(opts)
    M.remove(opts.args ~= "" and opts.args or nil)
  end, { nargs = "?" })
  vim.api.nvim_create_user_command("WorkspaceInfo", function()
    M.info()
  end, {})
end

local function setup_autocmds()
  local group = vim.api.nvim_create_augroup("Workspace", { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
      M.load()
    end,
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = WS_FILENAME,
    callback = function()
      M.load()
    end,
  })
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>ff",
        function()
          Snacks.picker.files({ dirs = M.dirs() })
        end,
        desc = "Find Files (workspace)",
      },
      {
        "<leader>fF",
        function()
          Snacks.picker.files({ dirs = M.dirs(), root = false })
        end,
        desc = "Find Files cwd (workspace)",
      },
      {
        "<leader>/",
        function()
          Snacks.picker.grep({ dirs = M.dirs() })
        end,
        desc = "Grep (workspace)",
      },
      {
        "<leader>sg",
        function()
          Snacks.picker.grep({ dirs = M.dirs() })
        end,
        desc = "Grep (workspace)",
      },
      {
        "<leader>sG",
        function()
          Snacks.picker.grep({ dirs = M.dirs(), root = false })
        end,
        desc = "Grep cwd (workspace)",
      },
      {
        "<leader>sw",
        function()
          Snacks.picker.grep({ dirs = M.dirs(), search = vim.fn.expand("<cword>") })
        end,
        desc = "Grep word (workspace)",
      },
      -- Workspace management keys
      {
        "<leader>We",
        function()
          M.edit()
        end,
        desc = "Edit workspace file",
      },
      {
        "<leader>Wr",
        function()
          M.reload()
        end,
        desc = "Reload workspace",
      },
      {
        "<leader>Wa",
        function()
          M.add()
        end,
        desc = "Add cwd to workspace",
      },
      {
        "<leader>Wd",
        function()
          local data = read_json()
          if not data or #data.folders == 0 then
            return
          end
          local ws_dir = vim.fn.fnamemodify(M.file_path, ":h")
          local paths = vim.tbl_map(function(e)
            return resolve_path(ws_dir, e.path)
          end, data.folders)
          vim.ui.select(paths, { prompt = "Remove folder:" }, function(choice)
            if choice then
              M.remove(choice)
            end
          end)
        end,
        desc = "Remove folder from workspace",
      },
      {
        "<leader>Wi",
        function()
          M.info()
        end,
        desc = "Workspace info",
      },
      {
        "<leader>Wf",
        function()
          pick_folder_yazi()
        end,
        desc = "Open folder in Yazi",
      },
    },
    init = function()
      setup_commands()
      setup_autocmds()
    end,
  },
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>srw",
        function()
          if not M.active then
            vim.notify("No active workspace", vim.log.levels.WARN)
            return
          end
          require("grug-far").open({
            prefills = { paths = table.concat(M.folders, " ") },
          })
        end,
        desc = "Search and Replace in Workspace",
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 1, {
        M.status,
        cond = function()
          return M.active
        end,
      })
    end,
  },
}
