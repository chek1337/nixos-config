{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
in
{
  vim = {
    tabline.nvimBufferline = {
      enable = true;

      mappings = {
        cycleNext = "<Tab>";
        cyclePrevious = "<S-Tab>";
        closeCurrent = null;
        pick = null;
        sortByExtension = null;
        sortByDirectory = null;
        sortById = null;
        moveNext = null;
        movePrevious = null;
      };

      setupOpts = {
        highlights = mkLuaInline ''
          (function()
            local scheme = vim.g.colors_name or ""
            return {
              fill = {
                bg = scheme:find("catppuccin") and "#181825"
                  or scheme == "gruvbox" and "#1d2021"
                  or "#222730",
              },
            }
          end)()
        '';

        options = {
          right_mouse_command = mkLuaInline "false";
          middle_mouse_command = mkLuaInline ''
            function(bufnum)
              vim.defer_fn(function()
                Snacks.bufdelete(bufnum)
              end, 100)
            end
          '';
          always_show_bufferline = true;
          separator_style = "thin";
          buffer_close_icon = "×";
          indicator.style = "none";
          hover = {
            enabled = false;
            delay = 200;
            reveal = [ "close" ];
          };
          diagnostics = false;
          sort_by = mkLuaInline ''
            function(buffer_a, buffer_b)
              local harpoon = require("harpoon")
              local list = harpoon:list()
              local harpoon_len = list:length()

              local function getHarpoonIndex(buf_id)
                if harpoon_len == 0 then return math.huge end
                local buf_path = vim.api.nvim_buf_get_name(buf_id)
                if buf_path == "" then return math.huge end
                local rel_path = vim.fn.fnamemodify(buf_path, ":.")
                for idx = 1, harpoon_len do
                  local item = list:get(idx)
                  if item and item.value == rel_path then return idx end
                end
                return math.huge
              end

              local idx_a = getHarpoonIndex(buffer_a.id)
              local idx_b = getHarpoonIndex(buffer_b.id)
              if idx_a == math.huge and idx_b == math.huge then
                return buffer_a.id < buffer_b.id
              end
              return idx_a < idx_b
            end
          '';
          numbers = mkLuaInline ''
            function(opts)
              local harpoon = require("harpoon")
              local list = harpoon:list()
              local buf_path = vim.api.nvim_buf_get_name(opts.id)
              if buf_path == "" then return "" end
              local rel_path = vim.fn.fnamemodify(buf_path, ":.")
              for idx = 1, list:length() do
                local item = list:get(idx)
                if item and item.value == rel_path then
                  return opts.raise(idx)
                end
              end
              return ""
            end
          '';
        };
      };
    };
  };
}
