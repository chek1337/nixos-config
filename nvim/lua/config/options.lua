-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.cursorline = false
vim.o.scrolloff = 2

vim.g.lazyvim_check_order = false

-- vim.opt.diffopt = vim.opt.diffopt + "iwhite"
vim.opt.fillchars:append({ diff = " " })

-- vim.diagnostic.config({
--   virtual_lines = {
--     current_line = true,
--   },
-- })
