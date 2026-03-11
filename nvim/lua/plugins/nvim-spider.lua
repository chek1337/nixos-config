-- positions vim's `w` will move to
-- if foo:find("%d") and foo == bar then print("[foo] has" .. bar) end
--    ^  ^^   ^  ^^  ^   ^   ^  ^   ^    ^    ^  ^  ^ ^  ^ ^  ^  ^ ^  -> 21

-- positions spider's `w` will move to
-- if foo:find("%d") and foo == bar then print("[foo] has" .. bar) end
--    ^   ^      ^   ^   ^   ^  ^   ^    ^       ^    ^    ^  ^    ^  -> 14

-- некоторый русский текст
return {
  "chrisgrieser/nvim-spider",
  event = "VeryLazy",
  dependencies = {
    { "folke/snacks.nvim" },
    -- { "rami3l/nvim-spider-utf8", build = "rockspec" },
  },
  opts = function()
    require("spider").setup({
      skipInsignificantPunctuation = true,
      subwordMovement = true,
      consistentOperatorPending = false,
      -- customPatterns = {
      --   patterns = {
      --     "[а-яА-ЯёЁ]+",
      --     "[%aа-яА-ЯёЁ][%wа-яА-ЯёЁ]*",
      --   },
      --   overrideDefault = false,
      -- },
    })

    local spider_toggle = Snacks.toggle({
      name = "Spider motions",
      get = function()
        return vim.g.spider_mode == true
      end,
      set = function(state)
        vim.g.spider_mode = state
        if state then
          vim.keymap.set({ "n", "o", "x" }, "w", function()
            require("spider").motion("w")
          end, { silent = true })
          vim.keymap.set({ "n", "o", "x" }, "e", function()
            require("spider").motion("e")
          end, { silent = true })
          vim.keymap.set({ "n", "o", "x" }, "b", function()
            require("spider").motion("b")
          end, { silent = true })
          vim.keymap.set({ "n", "o", "x" }, "ge", function()
            require("spider").motion("ge")
          end, { silent = true })
        else
          vim.keymap.del({ "n", "o", "x" }, "w")
          vim.keymap.del({ "n", "o", "x" }, "e")
          vim.keymap.del({ "n", "o", "x" }, "b")
          vim.keymap.del({ "n", "o", "x" }, "ge")
        end
      end,
    })

    spider_toggle:map("<leader>u*")
    spider_toggle:set(true)
  end,
  config = function(_, opts)
    require("treesitter-context").setup(opts)

    local context_toggle = Snacks.toggle({
      name = "Treesitter Context",
      get = function()
        return require("treesitter-context").enabled()
      end,
      set = function(state)
        if state then
          require("treesitter-context").enable()
        else
          require("treesitter-context").disable()
        end
      end,
    })

    context_toggle:map("<leader>uC")
  end,
}
