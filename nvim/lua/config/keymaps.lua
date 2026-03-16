-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode with jk" })
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode with jj" })
vim.keymap.set({ "n", "v" }, "q", "<Nop>", { desc = "Disable macros completely" })
vim.keymap.set({ "n", "v" }, "<M-q>", "q", { desc = "Write macros" })
vim.keymap.set("v", "u", "<Nop>", { desc = "Disable lowercase in visual mode" })
vim.keymap.set("v", "<M-u>", "u", { desc = "Change to lowercase" })
vim.keymap.set("v", "U", "<Nop>", { desc = "Disable uppercase in visual mode" })
vim.keymap.set("v", "<M-U>", "U", { desc = "Change to uppercase" })

vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left" })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down" })
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" })

vim.keymap.set("i", "<C-BS>", "<C-w>", { desc = "Delete word backward" })
vim.keymap.set("i", "\x1b[127;5~", "<C-w>", { desc = "Delete word backward (CSI)" })

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

vim.keymap.set("x", "p", [["_dP]])

Snacks.toggle.zoom():map("<C-W>z")

vim.keymap.set({ "n", "v" }, "x", '"_x')

vim.keymap.set("n", "J", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "H", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "L", "<Nop>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>M", "<cmd>Mason<CR>", { desc = "Open Mason" })
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Open Lazy" })
vim.keymap.del("n", "<leader>l")

vim.keymap.del("n", "<leader>dpp")
vim.keymap.del("n", "<leader>dph")

vim.keymap.set("n", "<leader>udd", function()
	local cfg = vim.diagnostic.config()
	local virt = cfg.virtual_lines

	if type(virt) == "table" and virt.current_line then
		vim.diagnostic.config({ virtual_lines = false })
	else
		vim.diagnostic.config({ virtual_lines = { current_line = true } })
	end
end, { desc = "Toggle virtual lines for current line only" })

vim.keymap.set("n", "<leader>udD", function()
	local cfg = vim.diagnostic.config()
	local virt = cfg.virtual_lines

	if virt == true or (type(virt) == "table" and not virt.current_line) then
		vim.diagnostic.config({ virtual_lines = false })
	else
		vim.diagnostic.config({ virtual_lines = true })
	end
end, { desc = "Toggle full virtual lines" })

-- notebook cell jump (based on commentstring + %%)
local function is_cell_border(lnum)
	local cs = vim.bo.commentstring
	if cs == "" then
		return false
	end

	local cell_marker = cs:format("%%")
	local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
	if not line then
		return false
	end

	return vim.startswith(vim.trim(line), cell_marker)
end

local function goto_next_cell()
	if vim.bo.commentstring == "" then
		vim.notify("Buffer has no commentstring set.", vim.log.levels.WARN)
		return
	end

	local cur = vim.api.nvim_win_get_cursor(0)[1]
	local last = vim.api.nvim_buf_line_count(0)

	local lnum = cur + 1
	while lnum <= last do
		if is_cell_border(lnum) then
			vim.api.nvim_win_set_cursor(0, { lnum, 0 })
			return
		end
		lnum = lnum + 1
	end

	vim.notify("No next notebook cell", vim.log.levels.INFO)
end

local function goto_prev_cell()
	if vim.bo.commentstring == "" then
		vim.notify("Buffer has no commentstring set.", vim.log.levels.WARN)
		return
	end

	local cur = vim.api.nvim_win_get_cursor(0)[1]

	local lnum = cur - 1
	while lnum >= 1 do
		if is_cell_border(lnum) then
			vim.api.nvim_win_set_cursor(0, { lnum, 0 })
			return
		end
		lnum = lnum - 1
	end

	vim.notify("No previous notebook cell", vim.log.levels.INFO)
end

-- keymaps
vim.keymap.set({ "n", "v" }, "]N", goto_next_cell, { desc = "Next notebook cell" })
vim.keymap.set({ "n", "v" }, "[N", goto_prev_cell, { desc = "Prev notebook cell" })
