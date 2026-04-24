{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
  getRootFn = # lua
    ''
      local function get_root()
        local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
        for _, client in pairs(clients) do
          if client.root_dir then return vim.fs.normalize(client.root_dir) end
        end
        local git = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
        if git and git ~= "" and not git:find("^fatal") then
          return vim.fs.normalize(git)
        end
        return vim.fs.normalize(vim.fn.getcwd())
      end
    '';
  formatFn = # lua
    ''
      local function format(component, text, hl_group)
        text = text:gsub("%%", "%%%%")
        if not hl_group or hl_group == "" then return text end
        component.hl_cache = component.hl_cache or {}
        local lualine_hl_group = component.hl_cache[hl_group]
        if not lualine_hl_group then
          local utils = require("lualine.utils.utils")
          local gui = vim.tbl_filter(function(x) return x end, {
            utils.extract_highlight_colors(hl_group, "bold") and "bold",
            utils.extract_highlight_colors(hl_group, "italic") and "italic",
          })
          lualine_hl_group = component:create_hl({
            fg = utils.extract_highlight_colors(hl_group, "fg"),
            gui = #gui > 0 and table.concat(gui, ",") or nil,
          }, "LV_" .. hl_group)
          component.hl_cache[hl_group] = lualine_hl_group
        end
        return component:format_hl(lualine_hl_group) .. text .. component:get_default_hl()
      end
    '';
  getHlColor = # lua
    ''
      local function get_hl_color(name)
        local ok, snacks = pcall(require, "snacks")
        if ok and snacks.util and snacks.util.color then
          return snacks.util.color(name)
        end
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        if hl.fg then
          return string.format("#%06x", hl.fg)
        end
        return nil
      end
    '';
in
{
  vim.statusline.lualine = {
    enable = true;
    setupOpts = {
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
          "alpha"
          "snacks_dashboard"
        ];
      };
      sections = {
        lualine_a = [ (mkLuaInline "{ 'mode' }") ];
        lualine_b = [
          (mkLuaInline "{ 'branch', icon = '' }")
        ];
        lualine_c = [
          (mkLuaInline ''
            (function()
              ${getRootFn}
              ${getHlColor}
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
                color = function()
                  return { fg = get_hl_color("Special") }
                end,
              }
            end)()
          '')
          (mkLuaInline ''
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
                length = 3,
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
          '')
          (mkLuaInline ''
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
          '')
        ];
        lualine_x = [
          (mkLuaInline ''
            {
              'diagnostics',
              symbols = {
                error = ' ',
                warn = ' ',
                info = ' ',
                hint = ' ',
              },
            }
          '')
          # for that?
          # (mkLuaInline ''
          #   {
          #     'diff',
          #     symbols = { added = ' ', modified = ' ', removed = ' ' },
          #   }
          # '')
          (mkLuaInline ''
            {
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
              icon = ' ',
            }
          '')
        ];
        lualine_y = [
          (mkLuaInline ''
            { 'filetype' }
          '')
        ];

        lualine_z = [ (mkLuaInline "{ 'location' }") ];
      };
      inactive_sections = {
        lualine_a = [ ];
        lualine_b = [ ];
        lualine_c = [ (mkLuaInline "{ 'filename' }") ];
        lualine_x = [ (mkLuaInline "{ 'location' }") ];
        lualine_y = [ ];
        lualine_z = [ ];
      };
    };
  };
}
