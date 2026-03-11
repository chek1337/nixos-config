return {
  "mg979/vim-visual-multi",
  enabled = false,
  branch = "master",
  event = "VeryLazy",
  init = function()
    vim.g.VM_maps = {
      ["Add Cursor Up"] = "<M-Up>",
      ["Add Cursor Down"] = "<M-Down>",
    }
    vim.g.VM_default_mappings = 0
  end,
}
