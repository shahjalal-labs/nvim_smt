vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true }) -- Escape terminal mode
vim.api.nvim_set_keymap("t", "<C-h>", [[<C-\><C-n><C-w>h]], { noremap = true }) -- Navigate left
vim.api.nvim_set_keymap("t", "<C-l>", [[<C-\><C-n><C-w>l]], { noremap = true }) -- Navigate right
vim.api.nvim_set_keymap("t", "<C-j>", [[<C-\><C-n><C-w>j]], { noremap = true }) -- Navigate down
vim.api.nvim_set_keymap("t", "<C-k>", [[<C-\><C-n><C-w>k]], { noremap = true }) -- Navigate up
vim.api.nvim_set_keymap("n", "<leader>tz", ":split | terminal<CR>", { noremap = true, silent = true })

-- floating terminal
--w: (start)╭──────────── floating_term ────────────╮
-- function _G.floating_term()
-- 	local buf = vim.api.nvim_create_buf(false, true)
--
-- 	local width = math.floor(vim.o.columns * 0.8)
-- 	local height = math.floor(vim.o.lines * 0.8)
-- 	local row = math.floor((vim.o.lines - height) / 2)
-- 	local col = math.floor((vim.o.columns - width) / 2)
--
-- 	local win = vim.api.nvim_open_win(buf, true, {
-- 		relative = "editor",
-- 		width = width,
-- 		height = height,
-- 		row = row,
-- 		col = col,
-- 		style = "minimal",
-- 		border = "rounded",
-- 	})
--
-- 	-- start terminal
-- 	vim.fn.termopen(vim.o.shell)
--
-- 	-- ✔ q closes terminal
-- 	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true })
--
-- 	-- ✔ jj returns to normal mode (terminal-mode -> normal mode)
-- 	vim.keymap.set("t", "jj", [[<C-\><C-n>]], { buffer = buf, silent = true })
--
-- 	-- ✔ automatically enter insert mode (shell mode)
-- 	vim.cmd("startinsert")
-- end
-- vim.keymap.set("n", "<leader>tf", floating_term, { desc = "Floating Terminal" })

-- Table to keep track of floating terminals
_G.FloatingTerminals = {}

-- Main floating terminal function
function _G.floating_term(opts)
	opts = opts or {}
	local direction = opts.direction or "center" -- "center", "vertical", "horizontal"
	local cmd = opts.cmd or vim.o.shell
	local title = opts.title or vim.fn.getcwd() -- show current directory by default

	-- Create new buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Determine window size
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	if direction == "vertical" then
		width = math.floor(vim.o.columns * 0.5)
		height = vim.o.lines - 2
		row = 1
		col = math.floor(vim.o.columns * 0.5)
	elseif direction == "horizontal" then
		width = vim.o.columns - 2
		height = math.floor(vim.o.lines * 0.3)
		row = vim.o.lines - height - 1
		col = 1
	end

	-- Open floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = title,
		title_pos = "center",
	})

	-- Start terminal
	vim.fn.termopen(cmd)

	-- Auto enter insert mode
	vim.cmd("startinsert")

	-- Keymaps
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true })
	vim.keymap.set("t", "jj", [[<C-\><C-n>]], { buffer = buf, silent = true })

	-- Save reference to table for multiple terminals
	table.insert(_G.FloatingTerminals, { buf = buf, win = win, cmd = cmd })
end

-- Keymaps to open terminals
vim.keymap.set("n", "<leader>tf", function()
	floating_term({ direction = "center" })
end, { desc = "Floating Terminal Center" })
vim.keymap.set("n", "<leader>tv", function()
	floating_term({ direction = "vertical" })
end, { desc = "Floating Terminal Vertical" })
vim.keymap.set("n", "<leader>th", function()
	floating_term({ direction = "horizontal" })
end, { desc = "Floating Terminal Horizontal" })

-- Optional: Switch between terminals
vim.keymap.set("n", "<leader>tN", function()
	if #_G.FloatingTerminals == 0 then
		return
	end
	local term = table.remove(_G.FloatingTerminals, 1)
	vim.api.nvim_set_current_win(term.win)
	table.insert(_G.FloatingTerminals, term)
end, { desc = "Next Floating Terminal" })

--w: (end)  ╰──────────── floating_term ────────────╯
