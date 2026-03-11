return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function(_, opts)
    local harpoon = require("harpoon")
    harpoon:setup(opts)
    local list = harpoon:list()

    local notify_harpoon = false
    local function refresh(action, extra)
      if notify_harpoon then
        local count = list:length()
        local msg = string.format("Harpoon [%s] → %d items", action, count)
        if extra then
          msg = msg .. " | " .. extra
        end
        vim.notify(msg, vim.log.levels.INFO, { title = "Harpoon" })
      end

      vim.defer_fn(function()
        vim.cmd("redrawtabline")
      end, 10)
    end

    ----------------------------------------------------------------
    -- Monkey-patch
    local orig_add = list.add
    list.add = function(self, ...)
      local result = orig_add(self, ...)
      refresh("add")
      return result
    end

    local orig_prepend = list.prepend
    list.prepend = function(self, ...)
      local result = orig_prepend(self, ...)
      refresh("prepend")
      return result
    end

    local orig_remove = list.remove
    list.remove = function(self, ...)
      local result = orig_remove(self, ...)
      refresh("remove")
      return result
    end

    local orig_remove_at = list.remove_at
    list.remove_at = function(self, idx, ...)
      local result = orig_remove_at(self, idx, ...)
      refresh("remove_at", "index " .. tostring(idx))
      return result
    end

    local orig_select = list.select
    list.select = function(self, idx, opts, ...)
      local item = self:get(idx)
      local extra = item and ("→ " .. vim.fn.fnamemodify(item.value, ":t")) or "(nil)"
      local result = orig_select(self, idx, opts, ...)
      refresh("select", extra)
      return result
    end

    local orig_next = list.next
    list.next = function(self, ...)
      local result = orig_next(self, ...)
      refresh("next")
      return result
    end

    local orig_prev = list.prev
    list.prev = function(self, ...)
      local result = orig_prev(self, ...)
      refresh("prev")
      return result
    end

    local orig_replace_at = list.replace_at
    list.replace_at = function(self, idx, new_item, ...)
      local result = orig_replace_at(self, idx, new_item, ...)
      refresh("replace_at", "index " .. tostring(idx))
      return result
    end

    local orig_clear = list.clear
    list.clear = function(self, ...)
      local result = orig_clear(self, ...)
      refresh("clear")
      return result
    end

    harpoon:extend({
      UI_CREATE = function(ctx)
        vim.api.nvim_create_autocmd({ "BufUnload", "WinClosed" }, {
          buffer = ctx.bufnr,
          once = true,
          callback = function(ev)
            if ev.buf == ctx.bufnr or ev.match == tostring(ctx.winid) then
              vim.defer_fn(function()
                refresh("ui_closed")
              end, 50)
            end
          end,
        })
      end,
    })

    local keys = {
      {
        "<leader>ha",
        function()
          list:add()
        end,
        desc = "Add current file to Harpoon",
      },
      {
        "<leader>hh",
        function()
          harpoon.ui:toggle_quick_menu(list)
        end,
        desc = "Harpoon quick menu",
      },
      {
        "<leader>hd",
        function()
          list:remove()
        end,
        desc = "Remove current file from Harpoon",
      },
      {
        "[g",
        function()
          list:prev()
        end,
        desc = "Prev Harpoon File",
      },
      {
        "]g",
        function()
          list:next()
        end,
        desc = "Next Harpoon File",
      },
    }

    for i = 1, 9 do
      table.insert(keys, {
        "<leader>" .. i,
        function()
          list:select(i)
        end,
        desc = "which_key_ignore",
      })
      table.insert(keys, {
        "<leader>h" .. i,
        function()
          list:select(i)
        end,
        desc = "Harpoon to File " .. i .. ' ("<leader>' .. i .. '")',
      })
      table.insert(keys, {
        "<leader>hd" .. i,
        function()
          list:remove_at(i)
        end,
        desc = "Harpoon Remove File " .. i,
      })
    end

    for _, key in ipairs(keys) do
      vim.keymap.set("n", key[1], key[2], { desc = key.desc })
    end
  end,

  opts = {
    settings = {
      save_on_toggle = true,
      sync_on_ui_close = true,
    },
  },
}
