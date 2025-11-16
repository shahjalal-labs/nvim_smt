vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true }) -- Escape terminal mode
vim.api.nvim_set_keymap("t", "<C-h>", [[<C-\><C-n><C-w>h]], { noremap = true }) -- Navigate left
vim.api.nvim_set_keymap("t", "<C-l>", [[<C-\><C-n><C-w>l]], { noremap = true }) -- Navigate right
vim.api.nvim_set_keymap("t", "<C-j>", [[<C-\><C-n><C-w>j]], { noremap = true }) -- Navigate down
vim.api.nvim_set_keymap("t", "<C-k>", [[<C-\><C-n><C-w>k]], { noremap = true }) -- Navigate up
vim.api.nvim_set_keymap("n", "<leader>tz", ":split | terminal<CR>", { noremap = true, silent = true })

-- floating terminal
function _G.floating_term()
	-- create a new scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- window size
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- open floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- turn the buffer into a terminal
	vim.fn.termopen(vim.o.shell)

	-- map "q" to close the terminal window
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true })
end

-- keybinding to open it
vim.keymap.set("n", "<leader>Tf", floating_term, { desc = "Floating Terminal" })
