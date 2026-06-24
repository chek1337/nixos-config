{ ... }:
let
  raw = code: { __raw = code; };

  gitStateFn = # lua
    ''
      local function get_git_state()
        local buf = vim.api.nvim_get_current_buf()
        local cached = vim.b[buf].lualine_git_state
        if cached ~= nil then return cached end

        local name = vim.api.nvim_buf_get_name(buf)
        local root = name ~= ""
          and vim.fs.root(name, { ".git" })
          or vim.fs.root(vim.fn.getcwd(), { ".git" })
        if not root then
          vim.b[buf].lualine_git_state = ""
          return ""
        end

        local gitpath = root .. "/.git"
        local dir = gitpath
        if vim.fn.isdirectory(gitpath) == 0 then
          local f = io.open(gitpath, "r")
          if f then
            local content = f:read("*a")
            f:close()
            local gitdir = content:match("gitdir:%s*(.-)%s*$")
            if gitdir then
              if not gitdir:match("^/") then
                gitdir = root .. "/" .. gitdir
              end
              dir = vim.fs.normalize(gitdir)
            end
          end
        end

        local state = ""
        if vim.fn.isdirectory(dir .. "/rebase-merge") == 1
          or vim.fn.isdirectory(dir .. "/rebase-apply") == 1 then
          state = " REBASING"
        elseif vim.fn.filereadable(dir .. "/MERGE_HEAD") == 1 then
          state = " MERGING"
        elseif vim.fn.filereadable(dir .. "/CHERRY_PICK_HEAD") == 1 then
          state = " PICKING"
        elseif vim.fn.filereadable(dir .. "/REVERT_HEAD") == 1 then
          state = " REVERTING"
        elseif vim.fn.filereadable(dir .. "/BISECT_LOG") == 1 then
          state = " BISECTING"
        end

        vim.b[buf].lualine_git_state = state
        return state
      end
    '';

  getRootFn = # lua
    ''
      local function get_root()
        local buf = vim.api.nvim_get_current_buf()
        local cached = vim.b[buf].lualine_root
        if cached then return cached end

        local root
        for _, client in pairs(vim.lsp.get_clients({ bufnr = buf })) do
          if client.root_dir then
            root = vim.fs.normalize(client.root_dir)
            break
          end
        end

        if not root then
          local bufname = vim.api.nvim_buf_get_name(buf)
          local start = bufname ~= "" and vim.fs.dirname(bufname) or vim.fn.getcwd()
          local git_marker = vim.fs.find({ ".git" }, { upward = true, path = start })[1]
          if git_marker then
            root = vim.fs.normalize(vim.fs.dirname(git_marker))
          end
        end

        if not root then
          root = vim.fs.normalize(vim.fn.getcwd())
        end

        vim.b[buf].lualine_root = root
        return root
      end
    '';

  formatFn = # lua
    ''
      local function format(_, text, hl_group)
        text = text:gsub("%%", "%%%%")
        if not hl_group or hl_group == "" then return text end
        return "%#Lualine_" .. hl_group .. "#" .. text .. "%*"
      end
    '';
in
{
  plugins.lualine = {
    enable = true;
    settings = {
      options = {
        theme = "auto";
        globalstatus = true;
        component_separators = {
          left = "";
          right = "";
        };
        section_separators = {
          left = "";
          right = "";
        };
        disabled_filetypes.statusline = [
          "snacks_dashboard"
        ];
      };
      sections = {
        lualine_a = [ (raw "{ 'mode' }") ];
        lualine_b = [
          (
            # lua
            raw ''
              (function()
                ${gitStateFn}
                return {
                  function()
                    local d = vim.b.gitsigns_status_dict
                    local head = (d and d.head) or ""
                    if head == "" then return "" end

                    local parts = { " " .. head }

                    local state = get_git_state()
                    if state ~= "" then
                      state = state:gsub("^%s+", "")
                      local ok, hl_mod = pcall(require, "lualine.highlight")
                      local section_hl_str = ok and hl_mod.format_highlight("b") or ""
                      local section_hl_name = section_hl_str:match("%%#(.-)#")
                      if section_hl_name then
                        local section_color = vim.api.nvim_get_hl(0, { name = section_hl_name, link = false })
                        local matchparen = vim.api.nvim_get_hl(0, { name = "MatchParen", link = false })
                        vim.api.nvim_set_hl(0, "Lualine_GitStateInline", {
                          fg = matchparen.fg,
                          bg = section_color.bg,
                          bold = true,
                        })
                        parts[#parts + 1] = "%#Lualine_GitStateInline#(" .. state .. ")" .. section_hl_str
                      else
                        parts[#parts + 1] = "(" .. state .. ")"
                      end
                    end

                    local extra = (_G.LualineGit and _G.LualineGit.get and _G.LualineGit.get()) or ""
                    if extra ~= "" then
                      parts[#parts + 1] = "[" .. extra .. "]"
                    end

                    return table.concat(parts, " ")
                  end,
                  cond = function()
                    local d = vim.b.gitsigns_status_dict
                    return d ~= nil and d.head ~= nil and d.head ~= ""
                  end,
                }
              end)()
            ''
          )
        ];
        lualine_c = [
          (
            # lua
            raw ''
              (function()
                ${getRootFn}
                return {
                  function()
                    local root = get_root()
                    return "󱉭 " .. vim.fs.basename(root)
                  end,
                  color = "Special",
                }
              end)()
            ''
          )
          (
            # lua
            raw ''
              (function()
                ${formatFn}
                local opts = {
                  modified_hl = "MatchParen",
                  directory_hl = "",
                  filename_hl = "Bold",
                  modified_sign = "",
                  readonly_icon = " 󰌾 ",
                  length = 0,
                }
                return {
                  function(self)
                    local path = vim.fn.expand("%:p")
                    if path == "" then return "" end
                    path = vim.fs.normalize(path)
                    local sep = package.config:sub(1, 1)
                    local parts = vim.split(path, "[\\/]")
                    if opts.length ~= 0 and #parts > opts.length then
                      parts = { parts[1], "…", unpack(parts, #parts - opts.length + 2, #parts) }
                    end
                    if opts.modified_hl and vim.bo.modified then
                      parts[#parts] = parts[#parts] .. opts.modified_sign
                      parts[#parts] = format(self, parts[#parts], opts.modified_hl)
                    else
                      parts[#parts] = format(self, parts[#parts], opts.filename_hl)
                    end
                    local dir = ""
                    if #parts > 1 then
                      dir = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
                      dir = format(self, dir .. sep, opts.directory_hl)
                    end
                    local readonly = ""
                    if vim.bo.readonly then
                      readonly = format(self, opts.readonly_icon, opts.modified_hl)
                    end
                    return dir .. parts[#parts] .. readonly
                  end,
                }
              end)()
            ''
          )
          (
            # lua
            raw ''
              (function()
                local ok, trouble = pcall(require, "trouble")
                if not ok then return {} end
                local symbols = trouble.statusline({
                  mode = "symbols",
                  groups = {},
                  title = false,
                  filter = { range = true },
                  format = "{kind_icon}{symbol.name:Normal}",
                  hl_group = "lualine_c_normal",
                })
                return {
                  symbols.get,
                  cond = function()
                    return vim.b.trouble_lualine ~= false and symbols.has()
                  end,
                }
              end)()
            ''
          )
        ];
        lualine_x = [
          (
            # lua
            raw ''
              {
                'diagnostics',
                symbols = {
                  error = ' ',
                  warn = ' ',
                  info = ' ',
                  hint = ' ',
                },
              }
            ''
          )
          (
            # lua
            raw ''
              {
                icon = ' ',
                function()
                  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
                  if #clients == 0 then return "" end
                  local names = {}
                  for _, client in pairs(clients) do
                    table.insert(names, client.name)
                  end
                  return " " .. table.concat(names, ", ")
                end,
                cond = function()
                  return #vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() }) > 0
                end,
              }
            ''
          )
        ];
        lualine_y = [ (raw "{ 'filetype' }") ];
        lualine_z = [ (raw "{ 'location' }") ];
      };
      inactive_sections = {
        lualine_a = [ ];
        lualine_b = [ ];
        lualine_c = [ (raw "{ 'filename' }") ];
        lualine_x = [ (raw "{ 'location' }") ];
        lualine_y = [ ];
        lualine_z = [ ];
      };
    };
  };

  extraConfigLua = ''
    do
      local group = vim.api.nvim_create_augroup("lualine_root_cache", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
          pcall(function() vim.b[args.buf].lualine_root = nil end)
        end,
      })
      vim.api.nvim_create_autocmd("DirChanged", {
        group = group,
        callback = function()
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            pcall(function() vim.b[b].lualine_root = nil end)
          end
        end,
      })
    end

    do
      _G.LualineGit = _G.LualineGit or {}
      _G.LualineGit.by_root = _G.LualineGit.by_root or {}
      _G.LualineGit.inflight = _G.LualineGit.inflight or {}

      local M = _G.LualineGit

      local function parse(out)
        local ahead, behind = 0, 0
        local unstaged, staged, untracked, conflicted = false, false, false, false
        for line in (out or ""):gmatch("[^\n]+") do
          local a, b = line:match("^# branch%.ab %+(%-?%d+) %-(%-?%d+)")
          if a then
            ahead, behind = tonumber(a) or 0, tonumber(b) or 0
          else
            local first = line:sub(1, 1)
            if first == "?" then
              untracked = true
            elseif first == "1" or first == "2" then
              local xy = line:sub(3, 4)
              if xy:sub(1, 1) ~= "." then staged = true end
              if xy:sub(2, 2) ~= "." then unstaged = true end
            elseif first == "u" then
              conflicted = true
            end
          end
        end
        local marks = (conflicted and "=" or "")
          .. (unstaged and "!" or "")
          .. (staged and "+" or "")
          .. (untracked and "?" or "")
        local ab = ""
        if ahead > 0 and behind > 0 then
          ab = "⇕"
        elseif ahead > 0 then
          ab = "⇡"
        elseif behind > 0 then
          ab = "⇣"
        end
        return marks .. ab
      end

      function M.refresh(root)
        if not root or M.inflight[root] then return end
        M.inflight[root] = true
        vim.system(
          { "git", "status", "--porcelain=v2", "--branch" },
          { cwd = root, text = true },
          vim.schedule_wrap(function(result)
            M.inflight[root] = nil
            if result.code == 0 then
              M.by_root[root] = parse(result.stdout or "")
            else
              M.by_root[root] = ""
            end
            pcall(vim.cmd, "redrawstatus")
          end)
        )
      end

      local function root_for(buf)
        buf = buf or vim.api.nvim_get_current_buf()
        local name = vim.api.nvim_buf_get_name(buf)
        if name ~= "" then
          return vim.fs.root(name, { ".git" })
        end
        return vim.fs.root(vim.fn.getcwd(), { ".git" })
      end

      function M.get(buf)
        local root = root_for(buf)
        if not root then return "" end
        if M.by_root[root] == nil then
          M.by_root[root] = ""
          M.refresh(root)
        end
        return M.by_root[root] or ""
      end

      local function refresh_all()
        for root, _ in pairs(M.by_root) do
          M.refresh(root)
        end
      end

      local group = vim.api.nvim_create_augroup("lualine_git_async", { clear = true })
      vim.api.nvim_create_autocmd({
        "FocusGained",
        "DirChanged",
        "ShellCmdPost",
        "BufWritePost",
        "CursorHold",
        "CursorHoldI",
      }, { group = group, callback = refresh_all })

      if M.timer then
        pcall(function()
          M.timer:stop()
          M.timer:close()
        end)
      end
      M.timer = vim.uv.new_timer()
      M.timer:start(2000, 2000, vim.schedule_wrap(refresh_all))

      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
          if M.timer then
            pcall(function()
              M.timer:stop()
              M.timer:close()
            end)
            M.timer = nil
          end
        end,
      })
    end

    do
      local group = vim.api.nvim_create_augroup("lualine_git_state_cache", { clear = true })
      local function invalidate_all()
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          pcall(function() vim.b[b].lualine_git_state = nil end)
        end
      end
      vim.api.nvim_create_autocmd({
        "FocusGained",
        "DirChanged",
        "ShellCmdPost",
        "BufWritePost",
        "CursorHold",
        "CursorHoldI",
      }, { group = group, callback = invalidate_all })
    end

    do
      local group = vim.api.nvim_create_augroup("lualine_custom_hl", { clear = true })
      local function setup_hl()
        local function fg_of(name)
          local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
          return hl.fg and string.format("#%06x", hl.fg) or nil
        end
        vim.api.nvim_set_hl(0, "Lualine_Bold", { bold = true })
        vim.api.nvim_set_hl(0, "Lualine_MatchParen", { fg = fg_of("MatchParen"), bold = true })
      end
      vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = setup_hl })
      setup_hl()
    end
  '';
}
