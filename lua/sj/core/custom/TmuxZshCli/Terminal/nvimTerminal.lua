vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true }) -- Escape terminal mode
vim.api.nvim_set_keymap("t", "<C-h>", [[<C-\><C-n><C-w>h]], { noremap = true }) -- Navigate left
vim.api.nvim_set_keymap("t", "<C-l>", [[<C-\><C-n><C-w>l]], { noremap = true }) -- Navigate right
vim.api.nvim_set_keymap("t", "<C-j>", [[<C-\><C-n><C-w>j]], { noremap = true }) -- Navigate down
vim.api.nvim_set_keymap("t", "<C-k>", [[<C-\><C-n><C-w>k]], { noremap = true }) -- Navigate up
vim.api.nvim_set_keymap("n", "<leader>tz", ":split | terminal<CR>", { noremap = true, silent = true })

-- floating terminal
function _G.floating_term()
	local buf = vim.api.nvim_create_buf(false, true)

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- start terminal
	vim.fn.termopen(vim.o.shell)

	-- ✔ q closes terminal
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true })

	-- ✔ jj returns to normal mode (terminal-mode -> normal mode)
	vim.keymap.set("t", "jj", [[<C-\><C-n>]], { buffer = buf, silent = true })

	-- ✔ automatically enter insert mode (shell mode)
	vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>tf", floating_term, { desc = "Floating Terminal" })
