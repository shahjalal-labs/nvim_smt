-- surfingKesy.lua using Hop.nvim for hint-based yanking
-- Assumes Hop is installed and configured; loads lazily
-- Yanks to system clipboard with "+; adjust if needed
-- Restore cursor after yank for "remote" effect
-- For Tree-sitter: Assumes nvim-treesitter-textobjects installed for 'yit'; otherwise, use yap for paragraphs

-- Custom yank word with hints
vim.keymap.set({ "n", "x", "o" }, "<leader>yw", function()
	local hop = require("hop")
	local old_pos = vim.api.nvim_win_get_cursor(0)
	hop.hint_words({ multi_windows = false }) -- Hint all visible words in current window
	vim.cmd('normal! "+yiw') -- Yank inner word to clipboard
	vim.api.nvim_win_set_cursor(0, old_pos)
end, { desc = "Yank word with Hop hints" })

-- Custom yank line with hints
vim.keymap.set({ "n", "x", "o" }, "<leader>yl", function()
	local hop = require("hop")
	local old_pos = vim.api.nvim_win_get_cursor(0)
	hop.hint_lines({ multi_windows = false }) -- Hint all line starts
	vim.cmd('normal! "+yy') -- Yank entire line to clipboard
	vim.api.nvim_win_set_cursor(0, old_pos)
end, { desc = "Yank line with Hop hints" })

-- Custom yank block/paragraph with hints (uses anywhere hint, then yank paragraph)
vim.keymap.set({ "n", "x", "o" }, "<leader>yb", function()
	local hop = require("hop")
	local old_pos = vim.api.nvim_win_get_cursor(0)
	hop.hint_anywhere({ multi_windows = false }) -- Hint anywhere for flexibility in blocks
	vim.cmd('normal! "+yap') -- Yank around paragraph (block)
	vim.api.nvim_win_set_cursor(0, old_pos)
end, { desc = "Yank block/paragraph with Hop hints" })

-- Custom yank Tree-sitter block with hints (uses anywhere hint, then yank TS node)
vim.keymap.set({ "n", "x", "o" }, "<leader>yt", function()
	local hop = require("hop")
	local old_pos = vim.api.nvim_win_get_cursor(0)
	hop.hint_anywhere({ multi_windows = false }) -- Hint anywhere; jump to node start approx
	vim.cmd('normal! "+yit') -- Yank inner Tree-sitter node (requires treesitter-textobjects)
	vim.api.nvim_win_set_cursor(0, old_pos)
end, { desc = "Yank Tree-sitter block with Hop hints" })

-- Optional: Customize Hop highlights for different types (add to your config)
-- vim.api.nvim_set_hl(0, "HopNextKey", { fg = "#ff00ff", bold = true }) -- Example for labels
-- To differentiate colors per mode: Temporarily set hl before hop call and restore after
-- e.g., for yw: vim.api.nvim_set_hl(0, "HopNextKey", { fg = "blue" }); hop.hint_words(); ...; reset hl
