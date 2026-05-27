{ ... }:
let
  raw = code: { __raw = code; };

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
          (raw "{ 'branch', icon = '' }")
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
                    local cwd = vim.fs.normalize(vim.fn.getcwd())
                    if root == cwd then return "" end
                    return "󱉭 " .. vim.fs.basename(root)
                  end,
                  cond = function()
                    return get_root() ~= vim.fs.normalize(vim.fn.getcwd())
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
                ${getRootFn}
                ${formatFn}
                local opts = {
                  relative = "cwd",
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
                    local root = get_root()
                    local cwd = vim.fs.normalize(vim.fn.getcwd())
                    local norm_path = path
                    if vim.fn.has("win32") == 1 then
                      norm_path = norm_path:lower()
                      root = root:lower()
                      cwd = cwd:lower()
                    end
                    if opts.relative == "cwd" and norm_path:find(cwd, 1, true) == 1 then
                      path = path:sub(#cwd + 2)
                    elseif norm_path:find(root, 1, true) == 1 then
                      path = path:sub(#root + 2)
                    end
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
