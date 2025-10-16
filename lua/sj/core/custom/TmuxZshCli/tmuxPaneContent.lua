-- Capture current tmux pane into a temp Neovim buffer using <leader>td
vim.keymap.set("n", "<leader>td", function()
	-- Generate a temporary file path
	local tmpfile = "/tmp/tmux_pane_" .. os.time() .. ".txt"

	-- Run the tmux capture-pane command
	local cmd = string.format("tmux capture-pane -pS -1000 > %s", tmpfile)
	os.execute(cmd)

	-- Open the captured content in a scratch-like buffer
	vim.cmd("edit " .. tmpfile)
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "hide"
	vim.bo.swapfile = false
end, { desc = "Open current tmux pane content in Neovim buffer" })
