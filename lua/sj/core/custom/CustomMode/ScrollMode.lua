local M = {
	active = false,
}

function M.toggle()
	M.active = not M.active
	if M.active then
		vim.notify("Scroll Mode: ON", vim.log.levels.INFO)
	else
		vim.notify("Scroll Mode: OFF", vim.log.levels.INFO)
	end
end

function M.disable()
	if M.active then
		M.active = false
		vim.notify("Scroll Mode: OFF", vim.log.levels.INFO)
	end
end

function M.scroll_down()
	if M.active then
		vim.api.nvim_input("10<C-d>")
	else
		vim.cmd("normal! w")
	end
end

function M.scroll_up()
	if M.active then
		vim.api.nvim_input("10<C-u>")
	else
		vim.cmd("normal! e")
	end
end

vim.keymap.set("n", "<leader>s,", M.toggle, { desc = "Toggle Scroll Mode" })
vim.keymap.set("n", "w", function()
	M.scroll_down()
end, { desc = "Scroll Down 10 or Move Word", noremap = true })
vim.keymap.set("n", "e", function()
	M.scroll_up()
end, { desc = "Scroll Up 10 or Move Word", noremap = true })
vim.keymap.set("n", "<Esc>", function()
	M.disable()
end, { desc = "Exit Scroll Mode", noremap = true })

return M
